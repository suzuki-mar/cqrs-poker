# frozen_string_literal: true

class GameRule
  MAX_HAND_SIZE = 5
  WHEEL_HIGH_CARD_INT = 5
  DECK_FULL_SIZE = 52

  def self.generate_standard_deck
    suit_number_pairs = HandSet::Card::VALID_SUITS.product(HandSet::Card::VALID_NUMBERS)
    suit_number_pairs.map { |suit, number| HandSet.build_card("#{suit}#{number}") }
  end

  def self.generate_deck_from_strings(card_strings)
    card_strings.map { |card_str| HandSet.build_card(card_str) }
  end

  def self.wheel_straight?(numbers)
    numbers == [2, 3, 4, 5, 14]
  end
end
