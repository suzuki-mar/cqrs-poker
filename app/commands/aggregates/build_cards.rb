# frozen_string_literal: true

module Aggregates
  class BuildCards
    def self.from_exchanged_event(hand, event)
      idx = hand.find_index { |c| c == event.to_event_data[:discarded_card] }
      return hand unless idx

      new_hand = hand.dup
      new_hand[idx] = event.to_event_data[:new_card]
      new_hand
    end

    def self.from_started_event(event)
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
