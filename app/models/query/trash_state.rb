module Query
  class TrashState < ApplicationRecord
    include DefineCurrentTurnColumn
    include DefineLastEventIdColumn
    include DefineGameNumberColumn
    serialize :discarded_cards, JSON

    validate :validate_discarded_cards_format

    def self.current_game(game_number)
      find_by(game_number: game_number.value)
    end

    private

    def validate_discarded_cards_format
      return if discarded_cards.is_a?(Array)

      errors.add(:discarded_cards, 'は配列でなければなりません')
    end
  end
end
