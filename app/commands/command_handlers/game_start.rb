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
        actual_version = aggregate_store.current_version
        return CommandResult.new(
          error: CommandErrors::VersionConflict.new(1, actual_version)
        )
      end

      result = append_event_to_store!(command)
      return result if result.error

      event_bus.publish(result.event)
      result
    end

    private

    attr_reader :event_bus, :aggregate_store

    def append_event_to_store!(command)
      board = Aggregates::BoardAggregate.load_for_current_state
      initial_hand = command.execute_for_game_start(board)
      event = SuccessEvents::GameStarted.new(initial_hand)

      aggregate_store.append(event, aggregate_store.current_version)
    end
  end
end
