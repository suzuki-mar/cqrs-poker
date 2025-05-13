FactoryBot.define do
  factory :player_hand_state, class: 'Query::PlayerHandState' do
    hand_set { Array.new(5) { Faker::Card.valid_card.to_s } }
    current_rank { HandSet::Rank::HIGH_CARD }
    current_turn { 1 }
    status { :initial }
    last_event_id { 1 }
  end
end
