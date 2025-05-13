module Query
  class Trash < ApplicationRecord
    include DefineCurrentTurnColumn
    include DefineLastEventIdColumn

    validates :discarded_cards, presence: true
    validate :validate_discarded_cards_format

    scope :latest, -> { order(current_turn: :desc).limit(1) }

    attr_accessor :last_event_id

    private

    def validate_discarded_cards_format
      return if discarded_cards.is_a?(Array)

      errors.add(:discarded_cards, 'は配列でなければなりません')
    end
  end
end
