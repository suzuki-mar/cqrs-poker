# frozen_string_literal: true

module EventFinalizer
  def self.execute(event, event_record)
    event.assign_ids(
      event_id: EventId.new(event_record.id),
      game_number: GameNumber.new(event_record.game_number)
    )

    event
  end
end
