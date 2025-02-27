FactoryBot.define do
  # ActiveRecordモデルのGameState用ファクトリ
  factory :game_state do
    hand_1 { Faker.valid_card.to_s }
    hand_2 { Faker.valid_card.to_s }
    hand_3 { Faker.valid_card.to_s }
    hand_4 { Faker.valid_card.to_s }
    hand_5 { Faker.valid_card.to_s }
    current_rank { Hand::Rank::HIGH_CARD }
    current_turn { 1 }
  end
    
end 