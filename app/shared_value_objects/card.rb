class Card
  VALID_SUITS = %w[♠ ♥ ♦ ♣].freeze
  VALID_RANKS = [ "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K" ].freeze

  attr_reader :suit, :rank

  def self.generate_available(used_cards = [])
    all_possible_cards = VALID_SUITS.flat_map do |suit|
      VALID_RANKS.map do |rank|
        new("#{suit}#{rank}")
      end
    end

    all_possible_cards - used_cards
  end

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

  def ==(other)
    other.is_a?(Card) && suit == other.suit && rank == other.rank
  end

  def eql?(other)
    self == other
  end

  def hash
    [ suit, rank ].hash
  end
end
