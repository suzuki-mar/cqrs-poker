# frozen_string_literal: true

module Aggregates
  class Store
    def append_event(event, game_number)
      raise if game_number.nil?

      expected_version = next_available_version_for_game(game_number)
      if expected_version <= Event.current_version_for_game(game_number)
        return ErrorResultBuilder.version_conflict(game_number, expected_version)
      end

      persist_and_finalize_event(event, game_number)
    rescue ActiveRecord::RecordInvalid => e
      expected_version ||= next_available_version_for_game(game_number)
      return ErrorResultBuilder.version_conflict(game_number, expected_version) if Event.version_conflict_error?(e)

      ErrorResultBuilder.validation_error(e, event)
    end

    def append_initial_event(event, game_number)
      raise if game_number.nil?

      event_record = create_event_record!(event, game_number)
      event.assign_ids(event_id: EventId.new(event_record.id), game_number: game_number)
      CommandResult.new(event: event)
    rescue ActiveRecord::RecordInvalid => e
      raise "イベントの保存に失敗しました: #{e.record.errors.full_messages.join(', ')}"
    end

    def load_all_events_in_order(game_number)
      raise if game_number.nil?

      Event.where(game_number: game_number.value).order(:occurred_at).map do |event_record|
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

    def load_board_aggregate_for_current_state(game_number)
      events = load_all_events_in_order(game_number)
      aggregate = Aggregates::BoardAggregate.new(game_number: game_number)
      events.each { |event| aggregate.apply(event) }
      aggregate
    end

    def build_board_aggregate
      Aggregates::BoardAggregate.new(game_number: nil)
    end

    delegate :current_version_for_game, to: :Event

    def next_available_version_for_game(game_number)
      current_version_for_game(game_number) + 1
    end

    private

    def create_event_record!(event, game_number)
      raise if game_number.nil?

      version = next_available_version_for_game(game_number)

      Event.create!(
        event_type: event.event_type,
        event_data: event.to_serialized_hash.to_json,
        occurred_at: Time.current,
        version: version,
        game_number: game_number.value
      )
    end

    def valid_event_type?(event)
      event.is_a?(GameStartedEvent) ||
        event.is_a?(CardExchangedEvent) ||
        event.is_a?(GameEndedEvent)
    end

    def persist_and_finalize_event(event, game_number)
      raise if game_number.nil?

      event_record = create_event_record!(event, game_number)
      event.assign_ids(event_id: EventId.new(event_record.id), game_number: game_number)
      CommandResult.new(event: event)
    end
  end
end
