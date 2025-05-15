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
      return error if error

      result = append_event_to_store!
      return result if result.error

      event_bus.publish(result.event)
      result
    end

    private

    attr_reader :event_bus, :aggregate_store, :params

    def build_error_if_needed
      error_message = build_error_message_of_game_status_if_needed ||
                      build_error_message_of_hand_state_in_hand_if_needed

      return nil unless error_message

      CommandResult.new(
        error: CommandErrors::InvalidCommand.new(
          command: params.command,
          reason: error_message
        )
      )
    end

    def build_error_message_of_game_status_if_needed
      error_message = nil
      error_message ||= '指定されたゲームが存在しません' unless Event.exists_game?(params.context.game_number)
      error_message ||= 'ゲームが進行中ではありません' unless aggregate_store.game_in_progress?
      error_message
    end

    def build_error_message_of_hand_state_in_hand_if_needed
      return 'デッキの残り枚数が不足しています' unless params.board.drawable?

      events = aggregate_store.load_all_events_in_order
      rebuilt_hand = events.reduce([]) { |acc, event| rebuild_hand_from_event(acc, event) }

      return '交換対象のカードが手札に存在しません' unless rebuilt_hand.include?(params.discarded_card)

      nil
    end

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
  end
end
