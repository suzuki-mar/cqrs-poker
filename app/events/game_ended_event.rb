# frozen_string_literal: true

class GameEndedEvent
  include AssignableIds

  def initialize(ended_at)
    @ended_at = ended_at
  end

  def self.event_type
    'game_ended'
  end

  delegate :event_type, to: :class

  def to_event_data
    {
      ended_at: ended_at
    }
  end

  # DB保存用
  def to_serialized_hash
    {
      ended_at: ended_at
    }
  end

  def self.from_event(event_record)
    event_data = JSON.parse(event_record.event_data, symbolize_names: true)
    ended_at = event_data[:ended_at]
    event = new(ended_at)

    EventFinalizer.execute(event, event_record)

    event
  end

  def self.from_event_data(event_data, event_id, game_number)
    ended_at = event_data[:ended_at]
    event = new(ended_at)
    event.assign_ids(event_id: event_id, game_number: game_number)
    event
  end

  private

  attr_reader :ended_at
end
