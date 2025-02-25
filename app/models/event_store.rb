class EventStore < ApplicationRecord
  validates :event_type, presence: true
  validates :event_data, presence: true
  validates :occurred_at, presence: true
end
