class GameStartedEvent
  EVENT_TYPE = 'game_started'.freeze

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

  def self.from_store(store)
    event_data = JSON.parse(store.event_data, symbolize_names: true)
    hand_data = event_data[:initial_hand]
    hand_cards = hand_data.map { |c| Card.new(c) }
    hand_set = ReadModels::HandSet.build(hand_cards)
    new(hand_set)
  end
end
