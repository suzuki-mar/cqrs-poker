class GameState < ApplicationRecord
  VALID_RANKS = ['HIGH_CARD', 'ONE_PAIR', 'TWO_PAIR', 'THREE_OF_A_KIND',
                 'STRAIGHT', 'FLUSH', 'FULL_HOUSE', 'FOUR_OF_A_KIND',
                 'STRAIGHT_FLUSH', 'ROYAL_FLUSH'].freeze

  validates :hand_1, :hand_2, :hand_3, :hand_4, :hand_5,
            presence: true,
            hand: { message: 'カードの表示形式が不正です' }

  validates :current_rank, presence: true, inclusion: { in: VALID_RANKS }
  validates :current_turn, presence: true, 
                          numericality: { 
                            only_integer: true,
                            greater_than_or_equal_to: 1,
                            less_than_or_equal_to: 100
                          }
end
