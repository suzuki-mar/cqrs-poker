# frozen_string_literal: true

class CommandHandler
  def initialize(event_bus)
    @event_bus = event_bus
    @aggregate_store = AggregateStore.new
  end

  def handle(command, context)
    events = aggregate_store.load_all_events_in_order
    board = Aggregates::BoardAggregate.load_from_events(events)
    strategy = build_strategy(context.type, command, context, board)

    invalid_event = strategy.build_invalid_command_event_if_needed
    if invalid_event
      event_bus.publish(invalid_event)
      return invalid_event
    end

    event = strategy.build_event_by_executing
    event_bus.publish(event)
    event
  end

  private

  attr_reader :event_bus, :aggregate_store

  def build_strategy(type, command, context, board)
    case type
    when CommandContext::Types::GAME_START
      HandlerStrategy::GameStart.new(command, context, board)
    when CommandContext::Types::EXCHANGE_CARD
      HandlerStrategy::ExchangeCard.new(command, context, board)
    else
      raise InvalidCommand, "不明なコマンドタイプです: #{type}"
    end
  end
end
