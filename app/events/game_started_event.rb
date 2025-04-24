class GameStartedEvent
  EVENT_TYPE = "game_started"

  def initialize(initial_hand)
    @initial_hand = initial_hand
  end

  def event_type
    EVENT_TYPE
  end

  def event_type_name
    EVENT_TYPE
  end

  def to_event_data
    {
      initial_hand: initial_hand.cards,
      evaluate: initial_hand.evaluate
    }
  end

  # DB保存用
  def to_serialized_hash
    {
      initial_hand: initial_hand.cards.map(&:to_s),
      evaluate: initial_hand.evaluate
    }
  end

  attr_reader :initial_hand

  private
end
