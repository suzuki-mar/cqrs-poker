# frozen_string_literal: true

module UseCaseHelper
  def self.build_command_handler(logger)
    event_listener = LogEventListener.new(logger)
    projection = Projection.new
    event_publisher = EventPublisher.new(projection: projection, event_listener: event_listener)
    EventBus.new(event_publisher)
    CommandHandler.new(EventBus.new(event_publisher))
  end
end
