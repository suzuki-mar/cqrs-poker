FactoryBot.define do
  factory :trash_state, class: 'Query::TrashState' do
    discarded_cards { CustomFaker.hand_set_strings(2) }
    current_turn { CustomFaker.turn }
    last_event_id { CustomFaker.event_id }
    game_number { CustomFaker.game_number }
  end
end
