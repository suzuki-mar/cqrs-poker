module Query
  class PlayerHandState < ApplicationRecord
    include DefineCurrentTurnColumn
    include DefineLastEventIdColumn
    include DefineGameNumberColumn

    enum :status, { initial: 0, started: 1, ended: 2 }

    scope :started, -> { where(status: :started) }

    validates :hand_set, presence: true
    validate :validate_hand_set_format

    validates :current_rank, presence: true,
                             inclusion: { in: HandSet::Rank::ALL }

    def started?
      status == 'started'
    end

    def self.find_current_session
      last
    end

    private

    def validate_hand_set_format
      return if HandSet.valid_hand_set_format?(hand_set)

      errors.add(:hand_set, "は#{GameSetting::MAX_HAND_SIZE}枚のカード文字列配列でなければなりません")
    end
  end
end
