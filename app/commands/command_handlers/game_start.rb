# frozen_string_literal: true

module CommandHandlers
  class GameStart
    def initialize(event_bus)
      @event_bus = event_bus
      @aggregate_store = Aggregates::Store.new
    end

    def handle(command, context)
      @command = command

      raise ArgumentError, 'このハンドラーはGAME_START専用です' unless context.type == CommandContext::Types::GAME_START

      result = append_event_to_store!
      return result if result.error

      event_bus.publish(result.event)
      result
    end

    private

    attr_reader :event_bus, :aggregate_store, :command

    def append_event_to_store!
      board = Aggregates::BoardAggregate.load_for_current_state
      initial_hand = command.execute_for_game_start(board)
      event = GameStartedEvent.new(initial_hand)
      game_number = GameNumber.build

      aggregate_store.append_initial_event(event, game_number)
    end
  end
end
