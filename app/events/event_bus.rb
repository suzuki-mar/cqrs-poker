# frozen_string_literal: true

class EventBus
  def initialize(event_publisher)
    @event_publisher = event_publisher
    @event_store_holder = Aggregates::Store.new
  end

  def publish(event)
    return if event.nil?

    # game_number未設定チェックのみ
    raise '[BUG] event.game_number未設定' if event.game_number.nil?

    Rails.logger.info "Event published: #{event.class.name}"
    @event_publisher.broadcast(:handle_event, event)
  end

  private

  attr_reader :event_publisher, :event_store_holder
end
