# frozen_string_literal: true

module CommandHandlers
  class GameStart
    def initialize(event_bus, custom_deck_cards = nil)
      @event_bus = event_bus
      @custom_deck_cards = custom_deck_cards
      @aggregate_store = Aggregates::Store.new
    end

    def handle(command)
      raise ArgumentError, '不正なコマンドです' unless command.is_a?(Commands::GameStart)

      board = aggregate_store.build_board_aggregate(custom_deck_cards)

      initial_deck_cards = board.deck.cards.dup
      initial_hand = board.start_game
      result = append_event_to_store!(initial_hand, initial_deck_cards)
      return result if result.error

      result.event or raise '不正な実行結果'

      event_bus.publish(result.event)
      result
    end

    private

    attr_reader :event_bus, :aggregate_store, :custom_deck_cards

    def append_event_to_store!(initial_hand, initial_deck_cards)
      event = GameStartedEvent.new(initial_hand, initial_deck_cards)
      game_number = GameNumber.build

      aggregate_store.append_initial_event(event, game_number)
    end
  end
end
