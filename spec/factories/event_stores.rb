FactoryBot.define do
  factory :event do
    event_type { 'game_started' }
    event_data { { key: 'value' }.to_json }
    occurred_at { Time.current }
  end

  factory :event_store do
    event_type { GameStartedEvent::EVENT_TYPE }
    # 他の属性も必要に応じて追加
  end
end
