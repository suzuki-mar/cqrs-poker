# frozen_string_literal: true

class EventBus
  def initialize(event_publisher:, event_listener:)
    @event_publisher = event_publisher
    @event_listener = event_listener
  end

  # イベントをリスナーに送信する
  def publish(event)
    Rails.logger.info "Event published: #{event.class.name}"
    @event_publisher.broadcast(event.class.name.underscore, event)

    # イベントリスナーに通知
    @event_listener.handle_event(event)
  end
end
