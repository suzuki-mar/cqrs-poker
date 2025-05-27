# frozen_string_literal: true

module Aggregates
  class Deck
    attr_reader :cards

    def initialize
      @cards = generate_initial_cards
    end

    def draw_initial_hand
      drawn_cards = Array.new(GameSetting::MAX_HAND_SIZE) { draw }
      HandSet.build(drawn_cards)
    end

    def draw
      raise ArgumentError, 'デッキの残り枚数が不足しています' if cards.empty?

      drawn_card = cards.sample
      @cards = cards - [drawn_card]
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

    private

    def generate_initial_cards
      suit_number_pairs = HandSet::Card::VALID_SUITS.product(HandSet::Card::VALID_NUMBERS)
      suit_number_pairs.map do |suit, number|
        HandSet.build_card("#{suit}#{number}")
      end
    end
  end
end
