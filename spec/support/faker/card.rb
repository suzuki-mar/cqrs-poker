module Faker
  module Card
    module_function

    def suit
      ::HandSet::Card::VALID_SUITS.sample
    end

    def rank
      ::HandSet::Card::VALID_RANKS.sample
    end

    def number_rank
      ::HandSet::Card::VALID_RANKS.grep(/\d+/).sample
    end

    def face_rank
      (::HandSet::Card::VALID_RANKS - ::HandSet::Card::VALID_RANKS.grep(/\d+/)).sample
    end

    def valid_card
      HandSet.card_from_string(card_str)
    end

    def invalid_card
      HandSet.card_from_string('@1')
    end

    def card_with_suit(suit_value)
      HandSet.card_from_string("#{suit_value}#{rank}")
    end

    def card_with_rank(rank_value)
      HandSet.card_from_string("#{suit}#{rank_value}")
    end

    def card_str
      "#{suit}#{rank}"
    end

    private_class_method :card_str
  end
end
