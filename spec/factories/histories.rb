FactoryBot.define do
  factory :history, class: 'Query::History' do
    hand_set { Array.new(5) { Faker::Card.valid_card.to_s } }
    rank { 1 }
    ended_at { Time.current }
    last_event_id { 1 }
  end
end
