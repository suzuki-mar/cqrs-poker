# frozen_string_literal: true

module Aggregates
  class BoardAggregate
    attr_reader :game_number, :deck, :trash, :current_turn, :last_event_id, :game_started, :game_ended, :current_hand

    def initialize(game_number: nil)
      @game_number = game_number
      @deck = Deck.new
      @trash = Trash.new
      @game_started = false
      @game_ended = false
      @current_turn = 0
      @last_event_id = nil
      @current_hand = nil
    end

    def apply(event)
      case event
      when GameStartedEvent
        apply_of_game_started(event)
      when CardExchangedEvent
        apply_of_card_exchanged(event)
      when GameEndedEvent
        apply_of_game_ended(event)
      end
      @last_event_id = event.event_id if event.event_id
    end

    def remaining_deck_count
      deck.remaining_count
    end

    delegate :draw_initial_hand, to: :deck

    delegate :draw, to: :deck

    def start_game
      draw_initial_hand
    end

    def finish_game
      # ゲーム終了のドメインロジック（現在は特に処理なし）
    end

    delegate :cards, to: :current_hand, prefix: true

    def drawable?
      deck.remaining_count.positive?
    end

    def game_in_progress?
      game_started && !game_ended
    end

    def game_ended?
      game_ended
    end

    def exists_game?
      game_started
    end

    def card_in_deck?(card)
      deck.has?(card)
    end

    def empty_trash?
      @trash.cards.empty?
    end

    def current_hand_cards
      current_hand&.cards || []
    end

    def apply_of_game_started(event)
      @game_started = true
      event_data = event.to_event_data
      initial_hand_cards = event_data[:initial_hand]
      initial_hand_cards.each { |card| @deck.remove(card) }
      @current_turn = 1
      @current_hand = HandSet.build(initial_hand_cards)
    end

    def apply_of_card_exchanged(event)
      event_data = event.to_event_data
      @trash.accept(event_data[:discarded_card])
      @deck.remove(event_data[:new_card])
      @current_turn += 1

      return unless @current_hand

      current_hand = @current_hand
      # @type var current_hand: HandSet
      new_cards = current_hand.cards.map { |card| card == event_data[:discarded_card] ? event_data[:new_card] : card }
      @current_hand = HandSet.build(new_cards)
    end

    def apply_of_game_ended(_event)
      @game_ended = true
    end
  end
end
