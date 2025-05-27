# このクラスはRDBのテーブルを表すActiveRecordモデルです。
# イベントオブジェクトの生成・復元はAggregates::Storeで行います。

class Event < ApplicationRecord
  include DefineGameNumberColumn

  EVENT_TYPES = %w[game_started card_exchanged game_ended invalid_command_event].freeze

  validates :event_type, presence: true
  validates :event_data, presence: true
  validate :validate_event_data_json
  validates :occurred_at, presence: true
  validate :validate_occurred_at_not_future_date
  validates :version, presence: true, uniqueness: { scope: :game_number }

  def self.current_version_for_game(game_number)
    where(game_number: game_number.value).maximum(:version).to_i
  end

  def self.version_conflict_error?(error)
    error.record.errors.details[:version]&.any? { |detail| detail[:error] == :taken }
  end

  def self.exists_by_types(game_number, event_types)
    # カラムは文字列型なので文字列に展開
    event_type_strings = event_types.map(&:to_s)

    # DBから一致するイベントタイプを検索
    found_types = where(game_number: game_number.value, event_type: event_type_strings).distinct.pluck(:event_type)

    # 結果をマッピング（シンボルキー → 存在するかどうかのブール値）
    # 型注釈を追加
    result = {} # @type var result: Hash[String | Symbol, bool]
    event_types.each do |type|
      result[type] = found_types.include?(type.to_s)
    end

    result
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
