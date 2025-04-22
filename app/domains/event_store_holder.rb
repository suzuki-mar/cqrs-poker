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

  def load_all_events_in_order
    EventStore.order(:occurred_at).map do |store|
      build_event_from_store(store)
    end
  end

  def latest_event
    store = EventStore.last
    return nil if store.nil?

    build_event_from_store(store)
  end

  def game_already_started?
    EventStore.where(event_type: GameStartedEvent::EVENT_TYPE).exists?
  end

  private

  def build_event_from_store(store)
    event_data = JSON.parse(store.event_data, symbolize_names: true)
    case store.event_type
    when GameStartedEvent::EVENT_TYPE
      initial_hand = HandSet.build(event_data[:initial_hand].map { |card_str| Card.new(card_str) })
      GameStartedEvent.new(initial_hand)
    when "card_exchanged"
      discarded_card = Card.new(event_data[:discarded_card])
      new_card = Card.new(event_data[:new_card])
      CardExchangedEvent.new(discarded_card, new_card)
    when "invalid_command_event"
      InvalidCommandEvent.new(command: event_data[:command], reason: event_data[:reason])
    else
      raise "未知のイベントタイプです: #{store.event_type}"
    end
  end
end
