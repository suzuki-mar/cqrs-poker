# frozen_string_literal: true

module Aggregates
  class Trash
    attr_reader :cards

    def initialize
      # @type var cards: Array[HandSet::Card]
      cards = []
      @cards = cards
    end

    def accept(card)
      @cards << card
    end
  end
end
