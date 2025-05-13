module Query
  class TrashState < ApplicationRecord
    include DefineCurrentTurnColumn
    include DefineLastEventIdColumn

    validates :discarded_cards, presence: true
    validate :validate_discarded_cards_format

    def self.current_game
      first
    end

    private

    def validate_discarded_cards_format
      return if discarded_cards.is_a?(Array)

      errors.add(:discarded_cards, 'は配列でなければなりません')
    end
  end
end
