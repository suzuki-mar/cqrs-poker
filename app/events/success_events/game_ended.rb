module SuccessEvents
  class GameEnded
    def initialize
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
      new
    end
  end
end
