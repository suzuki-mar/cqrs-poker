class GameStartedEvent
  EVENT_TYPE = "game_started"

  attr_reader :initial_hand

  def initialize(initial_hand)
    @initial_hand = initial_hand
  end

  def event_type
    EVENT_TYPE
  end

  def evaluate
    initial_hand.evaluate
  end

  def to_event_data
    {
      initial_hand: @initial_hand.cards.map(&:to_s)
    }
  end
end
