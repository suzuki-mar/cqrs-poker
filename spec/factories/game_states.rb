FactoryBot.define do
  factory :game_state do
    hand_1 { Faker::Card.valid_card.to_s }
    hand_2 { Faker::Card.valid_card.to_s }
    hand_3 { Faker::Card.valid_card.to_s }
    hand_4 { Faker::Card.valid_card.to_s }
    hand_5 { Faker::Card.valid_card.to_s }
    current_rank { GameState::VALID_RANKS.first }
    current_turn { 1 }
  end
end 