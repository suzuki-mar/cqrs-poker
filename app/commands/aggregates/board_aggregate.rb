# frozen_string_literal: true

module Aggregates
  class BoardAggregate
    attr_reader :game_ended, :exists_game, :game_in_progress

    def initialize(game_started:, game_ended:, exists_game:)
      @deck = Deck.new
      @trash = Trash.new
      @game_started = false
      @game_in_progress = game_started && !game_ended
      @game_ended = game_ended
      @exists_game = exists_game
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

    def game_in_progress?(game_number)
      exists_types = Event.exists_by_types(game_number, %w[game_started game_ended])
      exists_types['game_started'] && !exists_types['game_ended']
    end

    def game_ended?(game_number)
      exists_types = Event.exists_by_types(game_number, %w[game_started game_ended])
      exists_types['game_ended']
    end

    def exists_game?(game_number)
      Event.exists?(game_number: game_number.value)
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
