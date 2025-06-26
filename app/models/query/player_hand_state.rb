module Query
  class PlayerHandState < ApplicationRecord
    include DefineCurrentTurnColumn
    include DefineLastEventIdColumn
    include DefineGameNumberColumn
    serialize :hand_set, JSON

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

    def self.find_latest_by_event
      order(last_event_id: :desc).first
    end

    def self.build_for_game_start(game_number:, initial_hand:, evaluate:, event_id:)
      new(
        game_number: game_number.value,
        hand_set: initial_hand.map(&:to_s),
        current_rank: evaluate,
        current_turn: 1,
        status: 'started',
        last_event_id: event_id.value
      )
    end

    private

    def validate_hand_set_format
      return if HandSet.valid_hand_set_format?(hand_set)

      errors.add(:hand_set, "は#{GameRule::MAX_HAND_SIZE}枚のカード文字列配列でなければなりません")
    end
  end
end
