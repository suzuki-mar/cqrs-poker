# frozen_string_literal: true

module Aggregates
  class Store
    def append_event(event)
      create_event!(event)
      CommandResult.new(event: event)
    rescue ActiveRecord::RecordInvalid => e
      if version_conflict_error?(e)
        error = build_version_conflict_event(event, current_version)
        return CommandResult.new(error: error)
      end
      raise "イベントの保存に失敗しました: #{e.record.errors.full_messages.join(', ')}"
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
      raise "[BUG] latest_event: eventが_Event型でない: \\#{event}" unless valid_event_type?(event)

      event
    end

    def game_in_progress?
      started = Event.exists?(event_type: GameStartedEvent.event_type)
      ended = Event.exists?(event_type: GameEndedEvent.event_type)
      started && !ended
    end

    private

    def create_event!(event)
      version = event.is_a?(GameStartedEvent) ? 1 : current_version + 1

      Event.create!(
        event_type: event.event_type,
        event_data: event.to_serialized_hash.to_json,
        occurred_at: Time.current,
        version: version
      )
    end

    def current_version
      Event.maximum(:version) || 0
    end

    def valid_event_type?(event)
      event.is_a?(GameStartedEvent) ||
        event.is_a?(CardExchangedEvent) ||
        event.is_a?(GameEndedEvent)
    end

    def build_event_from_store(store)
      maps = {
        GameStartedEvent.event_type => GameStartedEvent,
        CardExchangedEvent.event_type => CardExchangedEvent,
        GameEndedEvent.event_type => GameEndedEvent
      }

      event_class = maps[store.event_type]
      raise "未知のイベントタイプです: #{store.event_type}" if event_class.nil?

      event = event_class.from_store(store)
      raise "イベントの復元に失敗しました: #{store.event_type}" if event.nil?
      raise "[BUG] build_event_from_store: eventが_Event型でない: #{event}" unless valid_event_type?(event)

      event
    end

    def version_conflict_error?(err)
      err.record.errors.details[:version]&.any? { |detail| detail[:error] == :taken }
    end

    def build_version_conflict_event(_event, expected_current_version)
      latest_version = Event.maximum(:version)
      CommandErrors::VersionConflict.new(latest_version + 1, expected_current_version)
    end

    def build_validation_error(error, command)
      raise ArgumentError, 'Command parameter is required for build_validation_error' if command.nil?

      CommandErrors::InvalidCommand.new(
        command: command,
        reason: error.record.errors.full_messages.join(', ')
      )
    end

    def build_version_conflict_result_if_needed(expected_current_version)
      current_stored_version = current_version
      return nil if expected_current_version == current_stored_version

      CommandResult.new(
        error: CommandErrors::VersionConflict.new(current_stored_version, expected_current_version)
      )
    end
  end
end
