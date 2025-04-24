class GameState < ApplicationRecord
  enum :status, { initial: 0, started: 1 }

  scope :started, -> { where(status: :started) }

  validates :hand1, :hand2, :hand3, :hand4, :hand5,
            presence: true,
            hand: { message: 'カードの表示形式が不正です' }

  validates :current_rank, presence: true,
                           inclusion: { in: ReadModels::HandSet::Rank::ALL }

  validates :current_turn, presence: true,
                           numericality: {
                             only_integer: true,
                             greater_than_or_equal_to: 1,
                             less_than_or_equal_to: 100
                           }

  after_initialize :set_default_values

  def assign_hand_number_from_set(hand_set)
    cards = hand_set.respond_to?(:cards) ? hand_set.cards : hand_set
    self.hand1 = cards[0].to_s
    self.hand2 = cards[1].to_s
    self.hand3 = cards[2].to_s
    self.hand4 = cards[3].to_s
    self.hand5 = cards[4].to_s
  end

  def hand_set
    [hand1, hand2, hand3, hand4, hand5]
  end

  def started?
    status == 'started'
  end

  def self.find_current_session
    last
  end

  private

  def set_default_values
    self.status ||= :initial
    self.current_turn ||= 1
    self.current_rank ||= ReadModels::HandSet::Rank::HIGH_CARD
  end
end
