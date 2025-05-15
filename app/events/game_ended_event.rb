# frozen_string_literal: true

class GameEndedEvent
  include AssignableIds

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

  def self.from_event(event_record)
    JSON.parse(event_record.event_data, symbolize_names: true)
    event = new
    if event_record.respond_to?(:id) && event_record.id &&
       event_record.respond_to?(:game_number) && event_record.game_number
      event.assign_ids(
        event_id: EventId.new(event_record.id),
        game_number: GameNumber.new(event_record.game_number)
      )
    end
    event
  end

  def self.from_event_data(_event_data, event_id, game_number)
    event = new
    event.assign_ids(event_id: event_id, game_number: game_number)
    event
  end
end
