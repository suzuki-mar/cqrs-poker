FactoryBot.define do
  factory :projection_version, class: 'Query::ProjectionVersion' do
    event_id { CustomFaker.event_id }
    projection_name { Query::ProjectionVersion.projection_names.keys.sample }

    trait :trash do
      projection_name { Query::ProjectionVersion.projection_names[:trash] }
    end
  end
end
