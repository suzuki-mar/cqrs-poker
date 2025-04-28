FactoryBot.define do
  # ActiveRecordモデルのPlayerHandState用ファクトリ
  factory :player_hand_state do
    hand_set { Array.new(5) { Faker::Card.valid_card.to_s } }
    current_rank { ReadModels::HandSet::Rank::HIGH_CARD }
    current_turn { 1 }
    status { :initial }
  end
end
