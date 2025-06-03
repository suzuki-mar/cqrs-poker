# frozen_string_literal: true

module AggregateTestHelper


  def self.load_board_aggregate(command_result)
    game_number = command_result.event.game_number
    aggregate_store = Aggregates::Store.new
    aggregate_store.load_board_aggregate_for_current_state(game_number)
  end

  def self.build_command_bus
    logger = TestLogger.new
    event_listener = EventListener::Log.new(logger)
    projection = EventListener::Projection.new
    event_publisher = EventPublisher.new(projection: projection, event_listener: event_listener)
    event_bus = EventBus.new(event_publisher)
    CommandBus.new(event_bus, logger)
  end
end
