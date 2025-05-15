# frozen_string_literal: true

module CommandHandlers
  class ExchangeCard
    def initialize(event_bus)
      @event_bus = event_bus
      @aggregate_store = Aggregates::Store.new
    end

    def handle(command)
      board = aggregate_store.load_board_aggregate_for_current_state
      discarded_card = command.discarded_card
      game_number = command.game_number

      error = ErrorResultBuilder.build_error_if_needed(
        discarded_card,
        game_number,
        aggregate_store,
        board
      )

      return error if error

      new_card = board.draw
      result = append_event_to_store!(discarded_card, new_card, game_number)
      return result if result.error

      event_bus.publish(result.event)
      result
    end

    private

    attr_reader :event_bus, :aggregate_store

    def append_event_to_store!(discarded_card, new_card, game_number)
      event = CardExchangedEvent.new(discarded_card, new_card)
      aggregate_store.append_event(event, game_number)
    end
  end
end
