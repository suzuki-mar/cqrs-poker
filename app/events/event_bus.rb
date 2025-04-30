# frozen_string_literal: true

class EventBus
  def initialize(event_publisher)
    @event_publisher = event_publisher
    @event_store_holder = Aggregates::Store.new
  end

  def publish(event)
    Rails.logger.info "Event published: #{event.class.name}"
    current_version = @event_store_holder.current_version
    @event_store_holder.append(event, current_version)
    @event_publisher.broadcast(:handle_event, event)
  end

  private

  attr_reader :event_publisher, :event_store_holder
end
