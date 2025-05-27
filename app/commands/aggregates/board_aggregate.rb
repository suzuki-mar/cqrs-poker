# frozen_string_literal: true

module Aggregates
  class BoardAggregate
    def initialize
      @deck = Deck.new
      @trash = Trash.new
      @game_started = false
    end

    # rubocop:disable Metrics/MethodLength
    def apply(event)
      case event
      when GameStartedEvent

        cards = build_cards_from_event(event)
        @game_started = true
        cards.each do |card|
          deck.remove(card) if deck.has?(card)
        end

      when CardExchangedEvent

        new_card = event.to_event_data[:new_card]
        deck.remove(new_card) if deck.has?(new_card)

      when GameEndedEvent
        # 何もしない
      end
    end
    # rubocop:enable Metrics/MethodLength

    def drawable?
      deck.remaining_count.positive?
    end

    # 現時点ではおこなうことはないがAgreegateの振る舞いとしてはったほうがいいのでメソッドを実装している
    def finish_game; end

    def build_cards_from_exchanged_event(hand, event)
      idx = hand.find_index { |c| c == event.to_event_data[:discarded_card] }
      return hand unless idx

      new_hand = hand.dup
      new_hand[idx] = event.to_event_data[:new_card]
      new_hand
    end

    private

    attr_reader :deck, :trash, :game_started

    delegate :draw_initial_hand, :draw, to: :deck

    def build_cards_from_event(event)
      event.to_event_data[:initial_hand].map do |card|
        if HandSet.card?(card)
          card
        else
          HandSet.build_card(card.to_s)
        end
      end
    end
  end
end
