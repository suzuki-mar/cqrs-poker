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
      when SuccessEvents::GameStarted
        apply_game_started_event(event)
      when SuccessEvents::CardExchanged
        apply_card_exchanged_event(event)
      end
    end

    def drawable?
      deck.remaining_count.positive?
    end

    private

    def apply_game_started_event(event)
      @game_started = true
      cards = event.to_event_data[:initial_hand].map { |c| HandSet.card?(c) ? c : HandSet.build_card_for_command(c) }
      cards.each do |card|
        deck.remove(card) if deck.has?(card)
      end
    end

    def apply_card_exchanged_event(event)
      new_card = event.to_event_data[:new_card]
      deck.remove(new_card) if deck.has?(new_card)
    end

    delegate :draw_initial_hand, to: :deck

    delegate :draw, to: :deck

    def discard_to_trash(card)
      trash.accept(card)
    end

    attr_reader :deck, :trash
  end
end
