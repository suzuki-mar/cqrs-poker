class GameStartCommand
  def self.execute(deck)
    new(deck).execute
  end

  private :initialize

  def initialize(deck)
    raise ArgumentError, "deck is required" if deck.nil?
    @deck = deck
  end

  def execute
    initial_hand = deck.generate_hand_set
    GameStartedEvent.new(initial_hand)
  end

  private

  attr_reader :deck
end
