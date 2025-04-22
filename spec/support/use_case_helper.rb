# frozen_string_literal: true

module UseCaseHelper
  def self.build_command_handler(logger)
    log_event_listener = LogEventListener.new(logger)
    event_publisher = EventPublisher.new(projection: Projection.new, event_listener: log_event_listener)
    event_bus = EventBus.new(event_publisher)
    CommandHandler.new(event_bus)
  end
end
