FactoryBot.define do
  # ActiveRecordモデルのGameState用ファクトリ
  factory :game_state do
    status { 'not_started' }
    initial_hand_data { [] }
  end
end
