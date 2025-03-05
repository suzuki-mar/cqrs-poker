class GameState < ApplicationRecord
  validates :hand_1, :hand_2, :hand_3, :hand_4, :hand_5,
            presence: true,
            hand: { message: "\u30AB\u30FC\u30C9\u306E\u8868\u793A\u5F62\u5F0F\u304C\u4E0D\u6B63\u3067\u3059" }

  validates :current_rank, presence: true,
            inclusion: { in: HandSet::Rank::ALL }

  validates :current_turn, presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 100
            }

  def assign_hand_number_from_set(hand_set)
    self.hand_1 = hand_set.cards[0].to_s
    self.hand_2 = hand_set.cards[1].to_s
    self.hand_3 = hand_set.cards[2].to_s
    self.hand_4 = hand_set.cards[3].to_s
    self.hand_5 = hand_set.cards[4].to_s
  end

  def hand_cards
    [ hand_1, hand_2, hand_3, hand_4, hand_5 ]
  end
end
