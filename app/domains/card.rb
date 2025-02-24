class Card
  VALID_SUITS = %w[♠ ♥ ♦ ♣].freeze
  VALID_RANKS = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'].freeze

  attr_reader :suit, :rank

  def initialize(card_str)
    @suit = card_str[0]
    @rank = card_str[1..-1]
  end

  def valid?
    VALID_SUITS.include?(@suit) && VALID_RANKS.include?(@rank)
  end

  def to_s
    "#{@suit}#{@rank}"
  end
end 