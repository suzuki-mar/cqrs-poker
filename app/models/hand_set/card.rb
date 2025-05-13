class HandSet
  class Card
    VALID_SUITS = %w[♠ ♥ ♦ ♣].freeze
    VALID_NUMBERS = %w[A 2 3 4 5 6 7 8 9 10 J Q K].freeze

    attr_reader :suit, :number

    def self.generate_available(used_cards = [])
      all_possible_cards = VALID_SUITS.flat_map do |suit|
        VALID_NUMBERS.map do |number|
          new("#{suit}#{number}")
        end
      end

      all_possible_cards - used_cards
    end

    def initialize(card_str)
      @suit = card_str[0]
      @number = card_str[1..]
    end

    def valid?
      VALID_SUITS.include?(@suit) && VALID_NUMBERS.include?(@number)
    end

    def to_s
      "#{@suit}#{@number}"
    end

    def ==(other)
      other.is_a?(Card) && suit == other.suit && number == other.number
    end

    def eql?(other)
      self == other
    end

    def hash
      [suit, number].hash
    end

    def same_rank?(other_card)
      other_card.is_a?(Card) && number == other_card.number
    end

    def same_number?(other_card)
      other_card.is_a?(Card) && number == other_card.number
    end
  end
end
