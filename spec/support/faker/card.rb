module Faker
  module Card
    module_function

    def suit
      ::Card::VALID_SUITS.sample
    end

    def rank
      ::Card::VALID_RANKS.sample
    end

    def number_rank
      ::Card::VALID_RANKS.grep(/\d+/).sample
    end

    def face_rank
      %w[A J Q K].sample
    end

    def valid_card
      ::Card.new(card_str)
    end

    def invalid_card
      ::Card.new('@1')
    end

    def card_with_suit(suit_value)
      ::Card.new("#{suit_value}#{rank}")
    end

    def card_with_rank(rank_value)
      ::Card.new("#{suit}#{rank_value}")
    end

    def card_str
      "#{suit}#{rank}"
    end

    private_class_method :card_str
  end
end
