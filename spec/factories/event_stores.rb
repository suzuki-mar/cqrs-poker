FactoryBot.define do
  factory :event_store do
    event_type { 'game_started' }
    event_data { { key: 'value' }.to_json }
    occurred_at { Time.current }
  end
end 