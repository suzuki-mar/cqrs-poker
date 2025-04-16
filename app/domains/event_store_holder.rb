class EventStoreHolder
  def append(event)
    EventStore.create(
      event_type: event.event_type,
      event_data: event.to_event_data.to_json,
      occurred_at: Time.current
    )
  end
end
