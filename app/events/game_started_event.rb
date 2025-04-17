class GameStartedEvent
  attr_reader :initial_hand

  def initialize(initial_hand)
    @initial_hand = initial_hand
  end

  def event_type
    EventType::GAME_STARTED
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
