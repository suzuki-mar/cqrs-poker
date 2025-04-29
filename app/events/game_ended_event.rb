class GameEndedEvent
  def self.event_type
    'game_ended'
  end

  delegate :event_type, to: :class

  def to_event_data
    {}
  end

  def to_serialized_hash
    {}
  end

  def self.from_store(_store)
    new
  end
end
