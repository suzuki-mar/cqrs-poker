# frozen_string_literal: true

module DefineLastEventIdColumn
  extend ActiveSupport::Concern

  included do
    attribute :last_event_id, :integer
    validates :last_event_id, presence: true,
                              numericality: {
                                only_integer: true,
                                greater_than_or_equal_to: 1,
                                message: 'イベントは1以上でなければなりません'
                              }
  end

  def to_event_id
    EventId.new(last_event_id)
  end
end
