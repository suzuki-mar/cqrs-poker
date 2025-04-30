# frozen_string_literal: true

class CommandHandler
  def initialize(event_bus)
    @event_bus = event_bus
    @aggregate_store = AggregateStore.new
  end

  def handle(command, context)
    strategy = build_strategy(context.type, command, context)
    invalid_event = strategy.build_invalid_command_event_if_needed
    event = invalid_event || strategy.build_event_by_executing
    result = append_to_aggregate_store(event, command)

    if result.is_a?(VersionConflictEvent) || result.is_a?(InvalidCommandEvent)
      event_bus.publish(result)
      return result
    end

    event_bus.publish(event)
    event
  end

  private

  attr_reader :event_bus, :aggregate_store

  def build_strategy(type, command, context)
    events = aggregate_store.load_all_events_in_order
    board = Aggregates::BoardAggregate.load_from_events(events)

    strategy_map = {
      CommandContext::Types::GAME_START => HandlerStrategy::GameStart,
      CommandContext::Types::EXCHANGE_CARD => HandlerStrategy::ExchangeCard,
      CommandContext::Types::END_GAME => HandlerStrategy::EndGame
    }

    klass = strategy_map[type]
    raise "不明なコマンドタイプです: #{type}" unless klass

    klass.new(command, context, board, aggregate_store)
  end

  def append_to_aggregate_store(event, command)
    aggregate_store.append(event, aggregate_store.current_version)
  rescue ActiveRecord::RecordInvalid => e
    error_event = aggregate_store.build_validation_error(e, command)
    event_bus.publish(error_event)
    error_event
  end
end
