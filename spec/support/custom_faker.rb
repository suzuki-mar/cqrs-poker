require_relative 'custom_faker/hand'
require_relative 'custom_faker/card'

module CustomFaker
  class << self
    delegate :suit, :rank, :number_rank, :face_number,
             :valid_card, :invalid_card, :card_with_suit, :card_with_rank,
             to: 'CustomFaker::Card'

    delegate :high_card_hand, :one_pair_hand, :two_pair_hand,
             :straight_flush_hand, :four_of_a_kind_hand, :full_house_hand,
             :flush_hand, :straight_hand, :three_of_a_kind_hand,
             :royal_flush_hand, :from_cards, :not_in_hand_card,
             to: 'CustomFaker::Hand'

    def event_type
      Faker::Lorem.word
    end

    def event_data
      { key: Faker::Lorem.word }.to_json
    end

    def occurred_at
      Faker::Time.backward(days: 14)
    end

    def ended_at
      Faker::Time.backward(days: 14)
    end

    def rank
      HandSet::Rank::ALL.sample
    end

    def event_id
      rand(1..1000)
    end

    delegate :card_with_number, to: :'CustomFaker::Card'
    delegate :card_of_face_number, to: 'CustomFaker::Card'

    def hand_set_strings(size = 5)
      Array.new(size) { CustomFaker::Card.valid_card.to_s }
    end

    def random_status
      %i[initial started ended].sample
    end

    def random_current_turn
      rand(1..100)
    end

    def status
      Query::PlayerHandState.statuses.keys.sample.to_sym
    end

    def turn
      rand(1..100)
    end
  end
end
