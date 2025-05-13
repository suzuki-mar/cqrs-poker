# frozen_string_literal: true

class GameEndedEvent
  def initialize
    @event_id = nil
  end

  def self.event_type
    'game_ended'
  end

  delegate :event_type, to: :class

  def to_event_data
    {}
  end

  # DB保存用
  def to_serialized_hash
    {}
  end

  def self.from_store(store)
    JSON.parse(store.event_data, symbolize_names: true)
    new
  end

  def event_id
    @event_id || (raise 'event_idが未設定です')
  end

  def event_id=(value)
    raise 'event_idは一度しか設定できません' if !@event_id.nil? && @event_id != value

    @event_id ||= value
  end

  def self.from_event_data(_event_data, id)
    event = new
    event.event_id = EventId.new(id)
    event
  end
end
