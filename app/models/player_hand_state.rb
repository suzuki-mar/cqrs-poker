class PlayerHandState < ApplicationRecord
  MAX_HAND_SIZE = 5
  enum :status, { initial: 0, started: 1 }

  scope :started, -> { where(status: :started) }

  validates :hand_set, presence: true
  validate :validate_hand_set_format

  validates :current_rank, presence: true,
                           inclusion: { in: HandSet::Rank::ALL }

  validates :current_turn, presence: true,
                           numericality: {
                             only_integer: true,
                             greater_than_or_equal_to: 1,
                             less_than_or_equal_to: 100
                           }

  def started?
    status == 'started'
  end

  def self.find_current_session
    last
  end

  private

  def validate_hand_set_format
    unless hand_set.is_a?(Array) && hand_set.size == MAX_HAND_SIZE && hand_set.all? do |c|
      c.present? && c.is_a?(String)
    end
      errors.add(:hand_set, 'は5枚のカード文字列配列でなければなりません')
    end
  end
end
