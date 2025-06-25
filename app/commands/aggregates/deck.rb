# frozen_string_literal: true

module Aggregates
  class Deck
    attr_reader :cards

    def initialize(cards: nil)
      @cards = cards || GameRule.generate_standard_deck
    end

    def draw_initial_hand
      drawn_cards = Array.new(GameRule::MAX_HAND_SIZE) { draw }
      HandSet.build(drawn_cards)
    end

    def draw
      raise ArgumentError, 'デッキの残り枚数が不足しています' if cards.empty?

      drawn_card = cards.first
      @cards = cards.drop(1)
      drawn_card
    end

    def remove(card)
      raise ArgumentError, '指定したカードはデッキに存在しません' unless cards.include?(card)

      @cards = cards - [card]
      card
    end

    def remaining_count
      cards.size
    end

    def has?(card)
      cards.include?(card)
    end
  end
end
