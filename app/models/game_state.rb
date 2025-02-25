class GameState < ApplicationRecord
  validates :hand_1, :hand_2, :hand_3, :hand_4, :hand_5,
            presence: true,
            hand: { message: 'カードの表示形式が不正です' }

  validates :current_rank, presence: true, 
            inclusion: { in: Hand::Rank::ALL }

  validates :current_turn, presence: true, 
            numericality: { 
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 100
            }
end
