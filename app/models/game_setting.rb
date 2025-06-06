# frozen_string_literal: true

class GameSetting
  include ActiveModel::Model

  MAX_HAND_SIZE = 5
  WHEEL_HIGH_CARD_INT = 5

  def self.wheel_straight?(numbers)
    numbers == [2, 3, 4, 5, 14]
  end
end
