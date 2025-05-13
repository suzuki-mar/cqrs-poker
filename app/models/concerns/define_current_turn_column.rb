# frozen_string_literal: true

module DefineCurrentTurnColumn
  extend ActiveSupport::Concern

  included do
    attribute :current_turn, :integer
    validates :current_turn, presence: true
    validate :validate_current_turn_range
  end

  private

  def validate_current_turn_range
    unless current_turn.is_a?(Integer)
      errors.add(:current_turn, 'は整数でなければなりません')
      return
    end

    return if current_turn >= 1 && current_turn <= 100

    errors.add(:current_turn, 'は1以上100以下の整数でなければなりません')
  end
end
