# frozen_string_literal: true

module CommandHandlers
  class ExchangeCard
    def initialize(event_bus)
      @event_bus = event_bus
      @aggregate_store = Aggregates::Store.new
    end

    def handle(command, context)
      @board = Aggregates::BoardAggregate.load_for_current_state

      raise_if_invalid_context(context)

      discarded_card = context.discarded_card
      # @type var discarded_card: _CardForCommand
      error = build_error_result_if_needed(command, @board, discarded_card)
      return error unless error.nil?

      result = append_event_to_store!(command, discarded_card)
      return result if result.error

      event_bus.publish(result.event)
      result
    end

    private

    attr_reader :event_bus, :aggregate_store, :board

    def raise_if_invalid_context(context)
      raise ArgumentError, 'このハンドラーはEXCHANGE_CARD専用です' unless context.type == CommandContext::Types::EXCHANGE_CARD
      raise ArgumentError, 'discarded_cardがnilです' if context.discarded_card.nil?
    end

    def append_event_to_store!(command, discarded_card)
      new_card = command.execute_for_exchange_card(@board)
      event = SuccessEvents::CardExchanged.new(discarded_card, new_card)

      aggregate_store.append(event, aggregate_store.current_version)
    end

    def build_error_result_if_needed(command, board, discarded_card)
      events = aggregate_store.load_all_events_in_order
      hand = events.reduce([]) { |acc, event| rebuild_hand_from_event(acc, event) }

      unless hand.include?(discarded_card)
        return CommandResult.new(
          error: CommandErrors::InvalidCommand.new(command: command, reason: '交換対象のカードが手札に存在しません')
        )
      end

      unless board.drawable?
        return CommandResult.new(
          error: CommandErrors::InvalidCommand.new(command: command, reason: 'デッキの残り枚数が不足しています')
        )
      end

      unless aggregate_store.game_in_progress?
        return CommandResult.new(
          error: CommandErrors::InvalidCommand.new(command: command, reason: 'ゲームが進行中ではありません')
        )
      end

      nil
    end

    def rebuild_hand_from_event(hand, event)
      if event.is_a?(SuccessEvents::GameStarted)
        hand = event.to_event_data[:initial_hand].map do |c|
          HandSet.build_card_for_command(c.is_a?(HandSet::Card) ? c.to_s : c)
        end
      elsif event.is_a?(SuccessEvents::CardExchanged)
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
  end
end
