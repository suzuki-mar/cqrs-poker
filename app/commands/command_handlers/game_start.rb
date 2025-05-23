# frozen_string_literal: true

module CommandHandlers
  class GameStart
    def initialize(event_bus)
      @event_bus = event_bus
      @aggregate_store = Aggregates::Store.new
    end

    def handle(command)
      @command = command

      board = aggregate_store.load_board_aggregate_for_current_state

      initial_hand = board.draw_initial_hand
      result = append_event_to_store!(initial_hand)
      return result if result.error

      event_bus.publish(result.event)
      result
    end

    private

    attr_reader :event_bus, :aggregate_store, :command

    def append_event_to_store!(initial_hand)
      event = GameStartedEvent.new(initial_hand)
      game_number = GameNumber.build

      aggregate_store.append_initial_event(event, game_number)
    end
  end
end
