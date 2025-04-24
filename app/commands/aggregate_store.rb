require "dry/monads"

class AggregateStore
  include Dry::Monads[:result]

  def current_version
    Event.maximum(:version) || 0
  end

  def append(event, expected_current_version)
    stored_version = current_version
    if expected_current_version < stored_version
      return Failure[VersionConflictEvent::EVENT_TYPE, VersionConflictEvent.new(event.event_type, stored_version, expected_current_version)]
    end

    if event.is_a?(GameStartedEvent) && Event.exists?(version: 1)
      return Failure[VersionConflictEvent::EVENT_TYPE, VersionConflictEvent.new(event.event_type, 1, expected_current_version)]
    end

    version = if event.is_a?(GameStartedEvent)
      1
    else
      expected_current_version + 1
    end
    Event.create!(
      event_type: event.event_type,
      event_data: event.to_serialized_hash.to_json,
      occurred_at: Time.current,
      version: version
    )
    Success()
  rescue ActiveRecord::RecordInvalid => e
    if e.record.errors.details[:version]&.any? { |err| err[:error] == :taken }
      latest_version = Event.maximum(:version)
      return Failure[VersionConflictEvent::EVENT_TYPE, VersionConflictEvent.new(event.event_type, latest_version + 1, expected_current_version)]
    end
    Failure[:validation_error, e.record.errors.full_messages]
  end

  def load_all_events_in_order
    Event.order(:occurred_at).map do |store|
      build_event_from_store(store)
    end
  end

  def latest_event
    store = Event.last
    return nil if store.nil?

    build_event_from_store(store)
  end

  def game_already_started?
    Event.where(event_type: GameStartedEvent::EVENT_TYPE).exists?
  end

  private

  def build_event_from_store(store)
    event_data = JSON.parse(store.event_data, symbolize_names: true)
    case store.event_type
    when GameStartedEvent::EVENT_TYPE
      hand_data = event_data[:initial_hand]
      hand_cards = hand_data.map { |c| Card.new(c) }
      hand_set = ReadModels::HandSet.build(hand_cards)
      GameStartedEvent.new(hand_set)
    when CardExchangedEvent::EVENT_TYPE
      discarded_card = event_data[:discarded_card]
      new_card = event_data[:new_card]
      discarded = Card.new(discarded_card)
      new_c = Card.new(new_card)
      CardExchangedEvent.new(discarded, new_c)
    when InvalidCommandEvent::EVENT_TYPE
      InvalidCommandEvent.new(command: event_data[:command], reason: event_data[:reason])
    when VersionConflictEvent::EVENT_TYPE
      VersionConflictEvent.new(
        event_data[:event_type],
        event_data[:expected_version],
        event_data[:actual_version]
      )
    else
      raise "未知のイベントタイプです: #{store.event_type}"
    end
  end
end
