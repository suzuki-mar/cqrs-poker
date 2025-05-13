FactoryBot.define do
  factory :trash, class: 'Query::Trash' do
    discarded_cards { Array.new(2) { Faker::Card.valid_card.to_s } }
    current_turn { 1 }
    last_event_id { 1 }
  end

  factory :trash_state, class: 'Query::TrashState' do
    discarded_cards { Array.new(2) { Faker::Card.valid_card.to_s } }
    current_turn { 1 }
    last_event_id { 1 }
  end
end
