class HandSet
  module Rank
    HIGH_CARD = "HIGH_CARD" # : String
    ONE_PAIR = "ONE_PAIR" # : String
    TWO_PAIR = "TWO_PAIR" # : String
    THREE_OF_A_KIND = "THREE_OF_A_KIND" # : String
    STRAIGHT = "STRAIGHT" # : String
    FLUSH = "FLUSH" # : String
    FULL_HOUSE = "FULL_HOUSE" # : String
    FOUR_OF_A_KIND = "FOUR_OF_A_KIND" # : String
    STRAIGHT_FLUSH = "STRAIGHT_FLUSH" # : String
    ROYAL_FLUSH = "ROYAL_FLUSH" # : String

    ALL = [
      HIGH_CARD,
      ONE_PAIR,
      TWO_PAIR,
      THREE_OF_A_KIND,
      STRAIGHT,
      FLUSH,
      FULL_HOUSE,
      FOUR_OF_A_KIND,
      STRAIGHT_FLUSH,
      ROYAL_FLUSH
    ].freeze # : Array[String]
  end

  attr_reader :cards # : Array[Card]

  private_class_method :new

  def initialize(cards)
    @cards = cards.freeze  # イミュータブルにする
  end

  def self.generate_initial
    deck = Deck.instance
    cards = deck.draw(5)
    new(cards)
  end

  # @rbs (Array[Card], Array[Card]) -> HandSet
  def redraw(discard_cards, new_cards)
    remaining_cards = @cards - discard_cards
    new_hand_cards = remaining_cards + new_cards
    self.class.new(new_hand_cards)
  end

  # @rbs () -> Rank
  def evaluate
    Evaluate.call(@cards)
  end

  # @rbs () -> bool
  def valid?
    return false unless @cards.is_a?(Array)
    return false unless @cards.size == 5
    @cards.all?(&:valid?)
  end
end
