class History < ApplicationRecord
  validates :hand_set, presence: true
  validates :rank, presence: true
  validates :ended_at, presence: true
  validate :ended_at_cannot_be_in_the_future

  private

  def ended_at_cannot_be_in_the_future
    return unless ended_at.present? && ended_at > Time.current

    errors.add(:ended_at, 'は未来の日時にできません')
  end
end
