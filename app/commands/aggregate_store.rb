require 'dry/monads'

class AggregateStore
  include Dry::Monads[:result]

  def current_version
    Event.maximum(:version) || 0
  end

  def append(event, expected_current_version)
    failer = build_failer_if_conflict(event, expected_current_version)
    return failer if failer.present?

    add_event_to_store!(event, expected_current_version)
    Dry::Monads::Result::Success.new(event)
  rescue ActiveRecord::RecordInvalid => e
    return build_version_conflict_event(event, expected_current_version) if version_conflict_error?(e)

    build_validation_error(e)
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
    Event.exists?(event_type: GameStartedEvent.event_type)
  end

  private

  def build_event_from_store(store)
    maps = {
      GameStartedEvent.event_type => GameStartedEvent,
      CardExchangedEvent.event_type => CardExchangedEvent,
      InvalidCommandEvent.event_type => InvalidCommandEvent,
      VersionConflictEvent.event_type => VersionConflictEvent
    }

    event = maps[store.event_type].from_store(store)
    raise "未知のイベントタイプです: #{store.event_type}" if event.nil?

    event
  end

  def build_failer_if_conflict(event, expected_current_version)
    stored_version = current_version
    if expected_current_version < stored_version
      return Failure[VersionConflictEvent.event_type,
                     VersionConflictEvent.new(stored_version, expected_current_version)]
    end

    # すでに開始済みの場合は何も返さない（上位層で判定・エラー生成）
    nil
  end

  def add_event_to_store!(event, expected_current_version)
    version = event.is_a?(GameStartedEvent) ? 1 : expected_current_version + 1

    Event.create!(
      event_type: event.event_type,
      event_data: event.to_serialized_hash.to_json,
      occurred_at: Time.current,
      version: version
    )
  end

  def version_conflict_error?(err)
    err.record.errors.details[:version]&.any? { |detail| detail[:error] == :taken }
  end

  def build_version_conflict_event(_event, expected_current_version)
    latest_version = Event.maximum(:version)
    Failure[VersionConflictEvent.event_type,
            VersionConflictEvent.new(latest_version + 1, expected_current_version)]
  end

  def build_validation_error(err)
    Failure[:validation_error, err.record.errors.full_messages]
  end
end
