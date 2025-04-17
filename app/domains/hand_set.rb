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

    NAMES = {
      HIGH_CARD => "\u30CF\u30A4\u30AB\u30FC\u30C9",
      ONE_PAIR => "\u30EF\u30F3\u30DA\u30A2",
      TWO_PAIR => "\u30C4\u30FC\u30DA\u30A2",
      THREE_OF_A_KIND => "\u30B9\u30EA\u30FC\u30AB\u30FC\u30C9",
      STRAIGHT => "\u30B9\u30C8\u30EC\u30FC\u30C8",
      FLUSH => "\u30D5\u30E9\u30C3\u30B7\u30E5",
      FULL_HOUSE => "\u30D5\u30EB\u30CF\u30A6\u30B9",
      FOUR_OF_A_KIND => "\u30D5\u30A9\u30FC\u30AB\u30FC\u30C9",
      STRAIGHT_FLUSH => "\u30B9\u30C8\u30EC\u30FC\u30C8\u30D5\u30E9\u30C3\u30B7\u30E5",
      ROYAL_FLUSH => "\u30ED\u30A4\u30E4\u30EB\u30B9\u30C8\u30EC\u30FC\u30C8\u30D5\u30E9\u30C3\u30B7\u30E5"
    }.freeze

    def self.japanese_name(rank)
      NAMES[rank]
    end
  end

  CARDS_IN_HAND = 5

  attr_reader :cards

  private_class_method :new

  def self.generate_initial(cards)
    raise ArgumentError, "Invalid hand" unless valid_cards?(cards)
    new(cards)
  end

  def initialize(cards)
    @cards = cards.freeze
  end

  def redraw(discard_cards, new_cards)
    remaining_cards = @cards - discard_cards
    new_hand_cards = remaining_cards + new_cards
    self.class.new(new_hand_cards)
  end

  def evaluate
    Evaluate.call(@cards)
  end

  def rank_name
    Rank::NAMES[evaluate]
  end

  def valid?
    self.class.valid_cards?(@cards)
  end

  private

  def self.valid_cards?(cards)
    return false unless cards.is_a?(Array)
    return false unless cards.size == CARDS_IN_HAND
    cards.all?(&:valid?)
  end
end
