# frozen_string_literal: true

module CommandHandlers
  class GameStart
    def initialize(event_bus)
      @event_bus = event_bus
      @aggregate_store = Aggregates::Store.new
    end

    def handle(command, context)
      raise ArgumentError, 'このハンドラーはGAME_START専用です' unless context.type == CommandContext::Types::GAME_START

      if aggregate_store.game_in_progress?
        invalid_event = FailureEvents::InvalidCommand.new(command: command, reason: 'already_started')
        event_bus.publish(invalid_event)
        invalid_event
      else
        events = aggregate_store.load_all_events_in_order
        board = Aggregates::BoardAggregate.load_from_events(events)
        initial_hand = command.execute_for_game_start(board)
        event = SuccessEvents::GameStarted.new(initial_hand)
        result = append_to_aggregate_store(event, command)
        if result.is_a?(FailureEvents::VersionConflict) || result.is_a?(FailureEvents::InvalidCommand)
          event_bus.publish(result)
          return result
        end
        event_bus.publish(event)
        event
      end
    end

    private

    attr_reader :event_bus, :aggregate_store

    def append_to_aggregate_store(event, command)
      aggregate_store.append(event, aggregate_store.current_version)
    rescue ActiveRecord::RecordInvalid => e
      error_event = aggregate_store.build_validation_error(e, command)
      event_bus.publish(error_event)
      error_event
    end
  end
end
