# このクラスはRDBのテーブルを表すActiveRecordモデルです。
# イベントオブジェクトの生成・復元はEventStoreHolderで行います。

class EventStore < ApplicationRecord
  validates :event_type, presence: true
  validates :event_data, presence: true
  validate :validate_event_data_json
  validates :occurred_at, presence: true
  validate :validate_occurred_at_not_future_date

  private

  def validate_event_data_json
    errors.add(:event_data, "must be valid JSON") unless valid_json?(event_data)
  end

  def valid_json?(json)
    return false if json.nil?
    JSON.parse(json)
    true
  rescue JSON::ParserError
    false
  end

  def validate_occurred_at_not_future_date
    if occurred_at.present? && occurred_at > Time.current
      errors.add(:occurred_at, "can't be in the future")
    end
  end
end
