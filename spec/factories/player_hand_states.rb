FactoryBot.define do
  factory :player_hand_state, class: 'Query::PlayerHandState' do
    hand_set { CustomFaker.hand_set_strings }
    current_rank { CustomFaker.rank }
    current_turn { CustomFaker.turn }
    status { Query::PlayerHandState.statuses.keys.sample.to_sym }
    last_event_id { CustomFaker.event_id }
    game_number { CustomFaker.game_number }
  end
end
