# frozen_string_literal: true

module Aggregates
  class BoardAggregate
    def initialize
      @deck = Deck.build
      @trash = Trash.new
      @game_started = false
    end

    def self.load_from_events(events)
      aggregate = new
      events.each { |event| aggregate.apply(event) }
      aggregate
    end

    def self.load_for_current_state
      events = Aggregates::Store.new.load_all_events_in_order
      aggregate = new
      events.each { |event| aggregate.apply(event) }
      aggregate
    end

    def apply(event)
      case event
      when GameStartedEvent
        cards = build_cards_from_event(event)
        apply_game_started_event_from_cards(cards)
      when CardExchangedEvent
        apply_card_exchanged_event(event)
      when GameEndedEvent
        apply_game_ended_event(event)
      end
    end

    def drawable?
      deck.remaining_count.positive?
    end

    # 現時点ではおこなうことはないがAgreegateの振る舞いとしてはったほうがいいのでメソッドを実装している
    def finish_game; end

    private

    attr_reader :deck, :trash, :game_started

    delegate :draw_initial_hand, :draw, to: :deck

    def build_cards_from_event(event)
      event.to_event_data[:initial_hand].map do |card|
        if HandSet.card?(card)
          card
        else
          HandSet.build_card_for_command(card)
        end
      end
    end

    def apply_game_started_event_from_cards(cards)
      @game_started = true
      cards.each do |card|
        deck.remove(card) if deck.has?(card)
      end
    end

    def apply_card_exchanged_event(event)
      new_card = event.to_event_data[:new_card]
      deck.remove(new_card) if deck.has?(new_card)
    end

    # 現時点ではおこなうことはないがAgreegateの振る舞いとしてはったほうがいいのでメソッドを実装している
    def apply_game_ended_event(event); end

    def discard_to_trash(card)
      trash.accept(card)
    end
  end
end
