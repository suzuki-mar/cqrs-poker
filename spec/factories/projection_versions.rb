FactoryBot.define do
  factory :projection_version, class: 'Query::ProjectionVersion' do
    event_id { 1 }
    projection_name { Query::ProjectionVersion.projection_names[:player_hand_state] }

    trait :trash do
      projection_name { Query::ProjectionVersion.projection_names[:trash] }
    end
  end
end
