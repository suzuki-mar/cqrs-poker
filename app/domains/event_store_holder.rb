class EventStoreHolder
  def append(event)
    EventStore.create!(
      event_type: event.event_type,
      event_data: event.to_event_data.to_json,
      occurred_at: Time.current
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "イベントの保存に失敗しました: #{e.message}"
    raise
  end

  def latest_event
    store = EventStore.last
    return nil if store.nil?

    event_data = JSON.parse(store.event_data, symbolize_names: true)
    case store.event_type
    when GameStartedEvent::EVENT_TYPE
      initial_hand = HandSet.generate_initial(event_data[:initial_hand].map { |card_str| Card.new(card_str) })
      GameStartedEvent.new(initial_hand)
    else
      raise "未知のイベントタイプです: #{store.event_type}"
    end
  end
end
