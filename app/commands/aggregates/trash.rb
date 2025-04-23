# frozen_string_literal: true

module Aggregates
  class Trash
    def initialize
      @cards = []
    end

    def accept(card)
      @cards << card
    end

    def cards
      @cards.dup
    end
  end
end
