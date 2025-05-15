# frozen_string_literal: true

module Aggregates
  class Store
    def append_event(event, game_number)
      persist_and_finalize_event(event, game_number)
    rescue ActiveRecord::RecordInvalid => e
      if version_conflict_error?(e)
        return ErrorBuilder.version_conflict_result(current_version) ||
               CommandResult.new(
                 error: CommandErrors::VersionConflict.new(current_version, current_version)
               )
      end

      CommandResult.new(error: ErrorBuilder.validation_error(e, event))
    end

    def append_initial_event(event, game_number)
      event_record = create_event_record!(event, game_number)
      event.assign_ids(event_id: EventId.new(event_record.id), game_number: game_number)
      CommandResult.new(event: event)
    rescue ActiveRecord::RecordInvalid => e
      raise "イベントの保存に失敗しました: #{e.record.errors.full_messages.join(', ')}"
    end

    def load_all_events_in_order
      Event.order(:occurred_at).map do |event_record|
        EventBuilder.execute(event_record)
      end
    end

    def latest_event
      event_record = Event.last
      return nil if event_record.nil?

      event = EventBuilder.execute(event_record)
      raise "[BUG] latest_event: eventが_Event型でない: \\#{event}" unless valid_event_type?(event)

      event
    end

    def game_in_progress?
      started = Event.exists?(event_type: GameStartedEvent.event_type)
      ended = Event.exists?(event_type: GameEndedEvent.event_type)
      started && !ended
    end

    def load_board_aggregate_for_current_state
      events = load_all_events_in_order
      aggregate = Aggregates::BoardAggregate.new
      events.each { |event| aggregate.apply(event) }
      aggregate
    end

    private

    def create_event_record!(event, game_number)
      version = Event.next_version_for(game_number)
      Event.create!(
        event_type: event.event_type,
        event_data: event.to_serialized_hash.to_json,
        occurred_at: Time.current,
        version: version,
        game_number: game_number.value
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

    def version_conflict_error?(err)
      err.record.errors.details[:version]&.any? { |detail| detail[:error] == :taken }
    end

    def persist_and_finalize_event(event, game_number)
      event_record = create_event_record!(event, game_number)
      event.assign_ids(event_id: EventId.new(event_record.id), game_number: game_number)
      CommandResult.new(event: event)
    end
  end
end
