FactoryBot.define do
  factory :history, class: 'Query::History' do
    hand_set { CustomFaker.hand_set_strings }
    rank { CustomFaker.rank }
    ended_at { CustomFaker.ended_at }
    last_event_id { CustomFaker.event_id }
    game_number { CustomFaker.game_number }
  end
end
