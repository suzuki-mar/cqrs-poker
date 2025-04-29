require_relative 'faker/hand'
require_relative 'faker/card'

module Faker
  class << self
    delegate :suit, to: 'HandSet::Card'

    delegate :rank, to: 'HandSet::Card'

    delegate :number_rank, to: 'HandSet::Card'

    delegate :face_rank, to: 'HandSet::Card'

    delegate :valid_card, to: 'HandSet::Card'

    delegate :invalid_card, to: 'HandSet::Card'

    delegate :card_with_suit, to: 'HandSet::Card'

    delegate :card_with_rank, to: 'HandSet::Card'

    def one_pair_hand
      Hand.one_pair
    end

    def high_card_hand
      Hand.high_card
    end

    def two_pair_hand
      Hand.two_pair
    end

    def straight_flush_hand
      Hand.straight_flush
    end

    def four_of_a_kind_hand
      Hand.four_of_a_kind
    end

    def full_house_hand
      Hand.full_house
    end

    def flush_hand
      Hand.flush
    end

    def straight_hand
      Hand.straight
    end

    def three_of_a_kind_hand
      Hand.three_of_a_kind
    end

    def hand_from_cards(cards)
      Hand.from_cards(cards)
    end

    private

    def double(attrs)
      instance_double(HandSet::Card, attrs)
    end
  end
end
