# frozen_string_literal: true

module CommandHandlers
  class EndGame
    def initialize(event_bus)
      @event_bus = event_bus
      @aggregate_store = Aggregates::Store.new
    end

    def handle(command, context)
      raise ArgumentError, 'このハンドラーはEND_GAME専用です' unless context.type == CommandContext::Types::END_GAME

      unless aggregate_store.game_in_progress?
        invalid_event = FailureEvents::InvalidCommand.new(command: command, reason: 'ゲームが進行中ではありません')
        event_bus.publish(invalid_event)
        return invalid_event
      end

      events = aggregate_store.load_all_events_in_order
      board = Aggregates::BoardAggregate.load_from_events(events)
      command.execute_for_end_game(board)
      event = SuccessEvents::GameEnded.new
      result = append_to_aggregate_store(event, command)
      if result.is_a?(FailureEvents::VersionConflict) || result.is_a?(FailureEvents::InvalidCommand)
        event_bus.publish(result)
        return result
      end
      event_bus.publish(event)
      event
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
