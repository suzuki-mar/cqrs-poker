FactoryBot.define do
  factory :event do
    event_type { 'game_started' }
    event_data { { key: 'value' }.to_json }
    occurred_at { Time.current }
  end
end
