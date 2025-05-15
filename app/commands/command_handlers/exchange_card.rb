# frozen_string_literal: true

module CommandHandlers
  class ExchangeCard
    def initialize(event_bus)
      @event_bus = event_bus
      @aggregate_store = Aggregates::Store.new
    end

    def handle(command, context)
      @params = Params.new(command, context, Aggregates::BoardAggregate.load_for_current_state)

      raise_if_invalid_context

      error = build_error_if_needed
      return error unless error.nil?

      result = append_event_to_store!
      return result if result.error

      event_bus.publish(result.event)
      result
    end

    def build_error_if_needed
      events = aggregate_store.load_all_events_in_order
      rebuilt_hand = events.reduce([]) { |acc, event| rebuild_hand_from_event(acc, event) }

      build_game_state_error_result_if_needed ||
        build_board_error_result_if_needed(rebuilt_hand)
    end

    private

    attr_reader :event_bus, :aggregate_store, :params

    def raise_if_invalid_context
      unless params.context.type == CommandContext::Types::EXCHANGE_CARD
        raise ArgumentError,
              'このハンドラーはEXCHANGE_CARD専用です'
      end
      raise ArgumentError, 'discarded_cardがnilです' if params.context.discarded_card.nil?
    end

    def append_event_to_store!
      new_card = params.command.execute_for_exchange_card(params.board)
      event = CardExchangedEvent.new(params.discarded_card, new_card)
      aggregate_store.append_event(event, params.context.game_number)
    end

    def build_board_error_result_if_needed(rebuilt_hand)
      unless rebuilt_hand.include?(params.discarded_card)
        return CommandResult.new(
          error: CommandErrors::InvalidCommand.new(command: params.command, reason: '交換対象のカードが手札に存在しません')
        )
      end

      unless params.board.drawable?
        return CommandResult.new(
          error: CommandErrors::InvalidCommand.new(command: params.command, reason: 'デッキの残り枚数が不足しています')
        )
      end

      nil
    end

    def rebuild_hand_from_event(hand, event)
      if event.is_a?(GameStartedEvent)
        hand = event.to_event_data[:initial_hand].map do |c|
          HandSet.build_card_for_command(c.is_a?(HandSet::Card) ? c.to_s : c)
        end
      elsif event.is_a?(CardExchangedEvent)
        hand = build_cards_from_exchanged_event(hand, event)
      end
      hand
    end

    def build_cards_from_exchanged_event(hand, event)
      idx = hand.find_index { |c| c == event.to_event_data[:discarded_card] }
      return hand unless idx

      new_hand = hand.dup
      new_hand[idx] = event.to_event_data[:new_card]
      new_hand
    end

    def build_game_state_error_result_if_needed
      unless aggregate_store.game_in_progress?
        return CommandResult.new(
          error: CommandErrors::InvalidCommand.new(command: params.command, reason: 'ゲームが進行中ではありません')
        )
      end
      nil
    end

    # --- ここから内部クラス ---
    class Params
      attr_reader :command, :discarded_card, :board, :context

      def initialize(command, context, board)
        @command = command
        @context = context
        @discarded_card = context.discarded_card
        @board = board
      end
    end
    private_constant :Params
    # --- ここまで ---
  end
end
