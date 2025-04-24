FactoryBot.define do
  # ActiveRecordモデルのGameState用ファクトリ
  factory :game_state do
    hand1 { Faker::Card.valid_card.to_s }
    hand2 { Faker::Card.valid_card.to_s }
    hand3 { Faker::Card.valid_card.to_s }
    hand4 { Faker::Card.valid_card.to_s }
    hand5 { Faker::Card.valid_card.to_s }
    current_rank { ReadModels::HandSet::Rank::HIGH_CARD }
    current_turn { 1 }
  end
end
