class GameStartCommand
  def initialize(event_store_domain:)
    @event_store_domain = event_store_domain
  end

  def execute
    initial_hand = Deck.instance.generate_hand_set
    event = GameStartedEvent.new(initial_hand)
    @event_store_domain.append(event)
    event
  end
end
