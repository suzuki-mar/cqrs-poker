# このクラスはRDBのテーブルを表すActiveRecordモデルです。
# イベントオブジェクトの生成・復元はAggregates::Storeで行います。

class Event < ApplicationRecord
  include DefineGameNumberColumn

  EVENT_TYPES = %w[game_started card_exchanged invalid_command_event].freeze

  validates :event_type, presence: true
  validates :event_data, presence: true
  validate :validate_event_data_json
  validates :occurred_at, presence: true
  validate :validate_occurred_at_not_future_date
  validates :version, presence: true, uniqueness: { scope: :game_number }

  def self.next_version_for(game_number)
    where(game_number: game_number.value).maximum(:version).to_i + 1
  end

  # 指定したgame_numberのゲームが存在するか判定する
  def self.exists_game?(game_number)
    exists?(game_number: game_number.value)
  end

  private

  def validate_event_data_json
    errors.add(:event_data, 'must be valid JSON') unless valid_json?(event_data)
  end

  def valid_json?(json)
    return false if json.nil?

    JSON.parse(json)
    true
  rescue JSON::ParserError
    false
  end

  def validate_occurred_at_not_future_date
    return unless occurred_at.present? && occurred_at > Time.current

    errors.add(:occurred_at, "can't be in the future")
  end
end
