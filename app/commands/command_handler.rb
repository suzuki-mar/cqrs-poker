# frozen_string_literal: true

class CommandHandler
  def initialize(event_bus)
    @event_bus = event_bus
    @event_store_holder = EventStoreHolder.new
  end

  def handle(command, context)
    events = event_store_holder.load_all_events_in_order
    board = BoardAggregate.load_from_events(events)

    # TODO: 異常系のテストのときにコメントアウトを解除する
    #    validate_command(command, context)

    event = build_event_by_executing(command, board, context)

    event_bus.publish(event)
    event
  end

  private

  attr_reader :event_bus, :event_store_holder

  def game_started?
    EventStore.exists?(event_type: "game_started")
  end

  def build_event_by_executing(command, board, context)
    case context.type
    when CommandContext::Types::GAME_START
      initial_hand = command.execute_for_game_start(board)
      GameStartedEvent.new(initial_hand)
    when CommandContext::Types::EXCHANGE_CARD
      discarded_card = context.discarded_card
      new_card = command.execute_for_exchange_card(board, discarded_card)
      CardExchangedEvent.new(discarded_card, new_card)
    else
      raise InvalidCommand, "不明なコマンドタイプです: #{context.type}"
    end
  end

  # TODO 後で実装をする
  def validate_command(command, context)
    # case command
    # when ExchangeCardCommand
    #   return DomainError.game_not_started unless game_started?
    #   return DomainError.card_not_specified unless context.discarded_card
    # end

    # nil
  end
end
