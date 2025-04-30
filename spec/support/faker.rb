require_relative 'faker/hand'
require_relative 'faker/card'

module Faker
  class << self
    delegate :suit, :rank, :number_rank, :face_rank,
             :valid_card, :invalid_card, :card_with_suit, :card_with_rank,
             to: 'HandSet::Card'

    delegate :high_card_hand, :one_pair_hand, :two_pair_hand,
             :straight_flush_hand, :four_of_a_kind_hand, :full_house_hand,
             :flush_hand, :straight_hand, :three_of_a_kind_hand,
             :royal_flush_hand, :from_cards, :not_in_hand_card,
             to: 'Faker::Hand'
  end
end
