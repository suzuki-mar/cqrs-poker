# frozen_string_literal: true

class GameRule
  include ActiveModel::Model

  MAX_HAND_SIZE = 5
  WHEEL_HIGH_CARD_INT = 5
  DECK_FULL_SIZE = 52

  def self.wheel_straight?(numbers)
    numbers == [2, 3, 4, 5, 14]
  end
end
