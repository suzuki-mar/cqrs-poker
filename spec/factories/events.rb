FactoryBot.define do
  factory :event do
    event_type { CustomFaker.event_type }
    event_data { CustomFaker.event_data }
    occurred_at { CustomFaker.occurred_at }
    game_number { CustomFaker.game_number }
  end
end
