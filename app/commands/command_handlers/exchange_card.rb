# frozen_string_literal: true

module CommandHandlers
  class ExchangeCard
    def initialize(event_bus)
      @event_bus = event_bus
      @aggregate_store = Aggregates::Store.new
    end

    def handle(command)
      board = Aggregates::BoardAggregate.load_for_current_state
      discarded_card = command.discarded_card
      game_number = command.game_number

      error = build_error_if_needed(discarded_card, game_number, board)
      return error if error

      new_card = board.draw
      result = append_event_to_store!(discarded_card, new_card, game_number)
      return result if result.error

      event_bus.publish(result.event)
      result
    end

    private

    attr_reader :event_bus, :aggregate_store

    def build_error_if_needed(discarded_card, game_number, board)
      error_message = build_error_message_of_game_status_if_needed(game_number) ||
                      build_error_message_of_hand_state_in_hand_if_needed(discarded_card, board, game_number)

      return nil unless error_message

      CommandResult.new(
        error: CommandErrors::InvalidCommand.new(
          command: ExchangeCardCommand.new(discarded_card, game_number),
          reason: error_message
        )
      )
    end

    def build_error_message_of_game_status_if_needed(game_number)
      error_message = nil
      error_message ||= '指定されたゲームが存在しません' unless Event.exists_game?(game_number)
      error_message ||= 'ゲームが進行中ではありません' unless aggregate_store.game_in_progress?
      error_message
    end

    def build_error_message_of_hand_state_in_hand_if_needed(discarded_card, board, _game_number)
      return 'デッキの残り枚数が不足しています' unless board.drawable?

      events = aggregate_store.load_all_events_in_order
      rebuilt_hand = events.reduce([]) { |acc, event| rebuild_hand_from_event(acc, event) }

      return '交換対象のカードが手札に存在しません' unless rebuilt_hand.include?(discarded_card)

      nil
    end

    def append_event_to_store!(discarded_card, new_card, game_number)
      event = CardExchangedEvent.new(discarded_card, new_card)
      aggregate_store.append_event(event, game_number)
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
  end
end
