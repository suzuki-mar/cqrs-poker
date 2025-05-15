# frozen_string_literal: true

module UseCaseHelper
  def self.build_command_handler(logger)
    event_listener = EventListener::Log.new(logger)
    projection = EventListener::Projection.new
    event_publisher = EventPublisher.new(projection: projection, event_listener: event_listener)
    EventBus.new(event_publisher)
    CommandHandler.new(EventBus.new(event_publisher))
  end

  def self.build_command_bus(logger)
    event_listener = EventListener::Log.new(logger)
    projection = EventListener::Projection.new
    event_publisher = EventPublisher.new(projection: projection, event_listener: event_listener)
    event_bus = EventBus.new(event_publisher)
    CommandBus.new(event_bus, logger)
  end
end
