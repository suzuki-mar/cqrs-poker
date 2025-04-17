# frozen_string_literal: true

class CommandHandler
  def initialize(event_bus)
    @event_bus = event_bus
  end

  def handle(command)
    @deck = recover_aggregate
    event = command.execute(deck)
    event_bus.publish(event)
  end

  private

  attr_reader :deck, :event_bus

  def recover_aggregate
    DeckAggregate.build
  end
end
