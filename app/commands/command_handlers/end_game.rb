# frozen_string_literal: true

module CommandHandlers
  class EndGame
    def initialize(event_bus)
      @event_bus = event_bus
      @aggregate_store = Aggregates::Store.new
    end

    def handle(command, context)
      raise ArgumentError, 'game_numberがnilです' if context.game_number.nil?

      # @type var game_number: GameNumber
      game_number = context.game_number

      unless aggregate_store.game_in_progress?
        return CommandResult.new(
          error: CommandErrors::InvalidCommand.new(command: command, reason: 'ゲームが進行中ではありません')
        )
      end

      result = append_event_to_store!(command, game_number)
      return result if result.error

      event_bus.publish(result.event)
      result
    end

    private

    attr_reader :event_bus, :aggregate_store

    def append_event_to_store!(command, game_number)
      board = Aggregates::BoardAggregate.load_for_current_state
      command.execute_for_end_game(board)
      event = GameEndedEvent.new

      aggregate_store.append_event(event, game_number)
    end
  end
end
