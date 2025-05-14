# frozen_string_literal: true

module Aggregates
  class Store
    def append_event(event, game_number)
      event = create_event!(event, game_number)
      CommandResult.new(event: event)
    rescue ActiveRecord::RecordInvalid => e
      if version_conflict_error?(e)
        error = build_version_conflict_event(event, current_version)
        return CommandResult.new(error: error)
      end
      raise "イベントの保存に失敗しました: #{e.record.errors.full_messages.join(', ')}"
    end

    def append_initial_event(event, game_number)
      event = create_event!(event, game_number)
      CommandResult.new(event: event)
    rescue ActiveRecord::RecordInvalid => e
      raise "イベントの保存に失敗しました: #{e.record.errors.full_messages.join(', ')}"
    end

    def load_all_events_in_order
      Event.order(:occurred_at).map do |event_record|
        build_event_from_event(event_record)
      end
    end

    def latest_event
      event_record = Event.last
      return nil if event_record.nil?

      event = build_event_from_event(event_record)
      raise "[BUG] latest_event: eventが_Event型でない: \\#{event}" unless valid_event_type?(event)

      event
    end

    def game_in_progress?
      started = Event.exists?(event_type: GameStartedEvent.event_type)
      ended = Event.exists?(event_type: GameEndedEvent.event_type)
      started && !ended
    end

    private

    def create_event!(event, game_number)
      version = event.is_a?(GameStartedEvent) ? 1 : current_version + 1

      event_record = Event.create!(
        event_type: event.event_type,
        event_data: event.to_serialized_hash.to_json,
        occurred_at: Time.current,
        version: version,
        game_number: game_number.value
      )
      event.assign_ids(event_id: EventId.new(event_record.id), game_number: game_number)
      event
    end

    def current_version
      Event.maximum(:version) || 0
    end

    def valid_event_type?(event)
      event.is_a?(GameStartedEvent) ||
        event.is_a?(CardExchangedEvent) ||
        event.is_a?(GameEndedEvent)
    end

    def build_event_from_event(event_record)
      maps = {
        GameStartedEvent.event_type => GameStartedEvent,
        CardExchangedEvent.event_type => CardExchangedEvent,
        GameEndedEvent.event_type => GameEndedEvent
      }

      raise_if_invalid_event_record(event_record, maps)

      event_class = maps[event_record.event_type]
      event_data = JSON.parse(event_record.event_data, symbolize_names: true)
      event_class.from_event_data(event_data, EventId.new(event_record.id), GameNumber.new(event_record.game_number))
    end

    def raise_if_invalid_event_record(event_record, maps)
      raise "未知のイベントタイプです: #{event_record.event_type}" unless maps.key?(event_record.event_type)

      event_class = maps[event_record.event_type]
      event_data = JSON.parse(event_record.event_data, symbolize_names: true)
      event = event_class.from_event_data(event_data, EventId.new(event_record.id),
                                          GameNumber.new(event_record.game_number))
      raise "イベントの復元に失敗しました: #{event_record.event_type}" if event.nil?
      raise "[BUG] build_event_from_event: eventが_Event型でない: #{event}" unless valid_event_type?(event)
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
