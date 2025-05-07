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
        return CommandResult.new(
          error: CommandErrors::InvalidCommand.new(command: command, reason: 'ゲームが進行中ではありません')
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
      command.execute_for_end_game(board)
      event = SuccessEvents::GameEnded.new

      aggregate_store.append(event, aggregate_store.current_version)
    end
  end
end
