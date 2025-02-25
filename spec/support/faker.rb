require_relative 'faker/hand'
require_relative 'faker/card'

module Faker
  class << self
    # Card
    def suit
      Card.suit
    end

    def rank
      Card.rank
    end

    def number_rank
      Card.number_rank
    end

    def face_rank
      Card.face_rank
    end

    def valid_card
      Card.valid_card
    end

    def invalid_card
      Card.invalid_card
    end

    def card_with_suit(suit_value)
      Card.card_with_suit(suit_value)
    end

    def card_with_rank(rank_value)
      Card.card_with_rank(rank_value)
    end

    # Hand
    def valid_hand
      Hand.valid_hand
    end

    def one_pair_hand
      Hand.one_pair_hand
    end

    def high_card_hand
      Hand.high_card_hand
    end

    def two_pair_hand
      Hand.two_pair_hand
    end

    def straight_flush_hand
      Hand.straight_flush_hand
    end

    def four_of_a_kind_hand
      Hand.four_of_a_kind_hand
    end

    def full_house_hand
      Hand.full_house_hand
    end

    def flush_hand
      Hand.flush_hand
    end

    def straight_hand
      Hand.straight_hand
    end

    def three_of_a_kind_hand
      Hand.three_of_a_kind_hand
    end

    private

    def double(attrs)
      instance_double(Card, attrs)
    end
  end
end 