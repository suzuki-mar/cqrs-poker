# frozen_string_literal: true

module DefineHandSetColumn
  extend ActiveSupport::Concern

  included do
    attribute :hand_set, :jsonb, default: -> { [] }
    validates :hand_set, presence: true
    validate :validate_hand_set_format
  end

  private

  def validate_hand_set_format
    return if HandSet.valid_hand_set_format?(hand_set)

    errors.add(:hand_set, "は#{GameSetting::MAX_HAND_SIZE}枚のカード文字列配列でなければなりません")
  end
end
