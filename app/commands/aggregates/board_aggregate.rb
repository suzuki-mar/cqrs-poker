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

    def apply(event)
      case event
      when GameStartedEvent
        apply_game_started_event(event)
      when CardExchangedEvent
        apply_card_exchanged_event(event)
      end
    end

    private

    def apply_game_started_event(event)
      @game_started = true
      cards = event.to_event_data[:initial_hand].map { |c| c.is_a?(Card) ? c : Card.new(c) }
      cards.each { |card| deck.remove(card) if deck.cards.include?(card) }
    end

    def apply_card_exchanged_event(event)
      deck.remove(event.new_card) if deck.cards.include?(event.new_card)
    end

    delegate :draw_initial_hand, to: :deck

    delegate :draw, to: :deck

    # カードを捨て札置き場に捨てる
    def discard_to_trash(card)
      trash.accept(card)
    end

    # デッキにカードが引けるかどうかを返すpublicメソッド
    def drawable?
      deck.size.positive?
    end

    attr_reader :deck, :trash
    public :drawable?
  end
end
