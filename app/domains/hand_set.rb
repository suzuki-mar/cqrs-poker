class HandSet
  module Rank
    HIGH_CARD = "HIGH_CARD"
    ONE_PAIR = "ONE_PAIR"
    TWO_PAIR = "TWO_PAIR"
    THREE_OF_A_KIND = "THREE_OF_A_KIND"
    STRAIGHT = "STRAIGHT"
    FLUSH = "FLUSH"
    FULL_HOUSE = "FULL_HOUSE"
    FOUR_OF_A_KIND = "FOUR_OF_A_KIND"
    STRAIGHT_FLUSH = "STRAIGHT_FLUSH"
    ROYAL_FLUSH = "ROYAL_FLUSH"

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
    ].freeze
  end

  CARDS_IN_HAND = 5

  attr_reader :cards

  private_class_method :new

  def initialize(cards)
    @cards = cards.freeze
  end

  def self.generate_initial
    deck = Deck.instance
    cards = deck.draw(CARDS_IN_HAND)
    new(cards)
  end

  def redraw(discard_cards, new_cards)
    remaining_cards = @cards - discard_cards
    new_hand_cards = remaining_cards + new_cards
    self.class.new(new_hand_cards)
  end

  def evaluate
    Evaluate.call(@cards)
  end

  def valid?
    return false unless @cards.is_a?(Array)
    return false unless @cards.size == CARDS_IN_HAND
    @cards.all?(&:valid?)
  end
end
