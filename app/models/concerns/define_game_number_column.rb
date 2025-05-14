# frozen_string_literal: true

module DefineGameNumberColumn
  extend ActiveSupport::Concern

  included do
    attribute :game_number, :integer
    validates :game_number, presence: true,
                            numericality: {
                              only_integer: true,
                              greater_than_or_equal_to: 1,
                              message: 'game_numberは1以上でなければなりません'
                            }
  end

  def to_game_number
    GameNumber.new(game_number)
  end
end
