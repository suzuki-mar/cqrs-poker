# frozen_string_literal: true

require 'dry/monads'

module Aggregates
  class Store
    include Dry::Monads[:result]

    def current_version
      Event.maximum(:version) || 0
    end

    def append(event, expected_current_version)
      # 失敗イベント（InvalidCommand, VersionConflict）は保存しない
      if event.is_a?(CommandErrors::InvalidCommand) || event.is_a?(CommandErrors::VersionConflict)
        return ::CommandResult.new(event: nil, error: event)
      end

      failer = build_failer_if_conflict(event, expected_current_version)
      return ::CommandResult.new(event: nil, error: failer) if failer

      add_event_to_store!(event, expected_current_version)
      ::CommandResult.new(event: event, error: nil)
    rescue ActiveRecord::RecordInvalid => e
      if version_conflict_error?(e)
        error = build_version_conflict_event(event, expected_current_version)
        return ::CommandResult.new(event: nil, error: error)
      end
      raise 'build_validation_errorにはcommandが必要です。呼び出し元で渡してください。'
    end

    def load_all_events_in_order
      Event.order(:occurred_at).map do |store|
        build_event_from_store(store)
      end
    end

    def latest_event
      store = Event.last
      return nil if store.nil?

      event = build_event_from_store(store)
      unless event.is_a?(SuccessEvents::GameStarted) || event.is_a?(SuccessEvents::CardExchanged) || event.is_a?(SuccessEvents::GameEnded)
        raise "[BUG] latest_event: eventが_Event型でない: \\#{event}"
      end

      event
    end

    def game_in_progress?
      started = Event.exists?(event_type: SuccessEvents::GameStarted.event_type)
      ended = Event.exists?(event_type: SuccessEvents::GameEnded.event_type)
      started && !ended
    end

    private

    def build_event_from_store(store)
      maps = {
        SuccessEvents::GameStarted.event_type => SuccessEvents::GameStarted,
        SuccessEvents::CardExchanged.event_type => SuccessEvents::CardExchanged,
        SuccessEvents::GameEnded.event_type => SuccessEvents::GameEnded
      }

      event = maps[store.event_type].from_store(store)
      raise "未知のイベントタイプです: \\#{store.event_type}" if event.nil?
      unless event.is_a?(SuccessEvents::GameStarted) || event.is_a?(SuccessEvents::CardExchanged) || event.is_a?(SuccessEvents::GameEnded)
        raise "[BUG] build_event_from_store: eventが_Event型でない: \\#{event}"
      end

      event
    end

    def build_failer_if_conflict(_event, expected_current_version)
      stored_version = current_version
      return unless expected_current_version < stored_version

      CommandErrors::VersionConflict.new(stored_version, expected_current_version)
    end

    def add_event_to_store!(event, expected_current_version)
      version = event.is_a?(SuccessEvents::GameStarted) ? 1 : expected_current_version + 1

      Event.create!(
        event_type: event.event_type,
        event_data: event.to_serialized_hash.to_json,
        occurred_at: Time.current,
        version: version
      )
    end

    def version_conflict_error?(err)
      err.record.errors.details[:version]&.any? { |detail| detail[:error] == :taken }
    end

    def build_version_conflict_event(_event, expected_current_version)
      latest_version = Event.maximum(:version)
      CommandErrors::VersionConflict.new(latest_version + 1, expected_current_version)
    end

    def build_validation_error(err, command)
      CommandErrors::InvalidCommand.new(command: command, reason: err.record.errors.full_messages.join(', '))
    end
  end
end
