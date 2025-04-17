class GameState < ApplicationRecord
  enum :status, { initial: 0, started: 1 }

  scope :started, -> { where(status: :started) }

  validates :hand_1, :hand_2, :hand_3, :hand_4, :hand_5,
            presence: true,
            hand: { message: "カードの表示形式が不正です" }

  validates :current_rank, presence: true,
            inclusion: { in: HandSet::Rank::ALL }

  validates :current_turn, presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 100
            }

  after_initialize :set_default_values

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

  def started?
    status == "started"
  end

  private

  def set_default_values
    self.status ||= :initial
    self.current_turn ||= 1
    self.current_rank ||= HandSet::Rank::HIGH_CARD
  end
end
