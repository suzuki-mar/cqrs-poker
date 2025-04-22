# frozen_string_literal: true

class CommandHandler
  def initialize(event_bus)
    @event_bus = event_bus
    @event_store_holder = EventStoreHolder.new
  end

  def handle(command, context)
    events = event_store_holder.load_all_events_in_order
    board = BoardAggregate.load_from_events(events)

    invalid_event = build_invalid_command_event_if_needed(command, context)
    if invalid_event
      event_bus.publish(invalid_event)
      return invalid_event
    end

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
      current_game_state = GameState.find_current_session
      hand_set = HandSet.build(current_game_state.hand_set.map { |str| Card.new(str) })
      unless hand_set.include?(discarded_card)
        return InvalidCommandEvent.new(command: command, reason: "交換対象のカードが手札に存在しません")
      end
      unless board.drawable?
        return InvalidCommandEvent.new(command: command, reason: "デッキの残り枚数が不足しています")
      end
      new_card = command.execute_for_exchange_card(board, discarded_card)
      CardExchangedEvent.new(discarded_card, new_card)
    else
      raise InvalidCommand, "不明なコマンドタイプです: #{context.type}"
    end
  end

  def build_invalid_command_event_if_needed(command, context)
    case context.type
    when CommandContext::Types::GAME_START
      if event_store_holder.game_already_started?
        return InvalidCommandEvent.new(command: command, reason: "ゲームはすでに開始されています")
      end
    end
    nil
  end
end
