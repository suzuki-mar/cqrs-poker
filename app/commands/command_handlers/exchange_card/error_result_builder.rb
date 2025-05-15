module CommandHandlers
  class ExchangeCard
    class ErrorResultBuilder
      class << self
        def build_error_if_needed(discarded_card, game_number, aggregate_store, board)
          error_message = build_error_message_of_game_status_if_needed(aggregate_store, game_number) ||
                          build_error_message_of_hand_state_in_hand_if_needed(aggregate_store, discarded_card,
                                                                              board, game_number)

          return nil unless error_message

          CommandResult.new(
            error: CommandErrors::InvalidCommand.new(
              command: Commands::ExchangeCard.new(discarded_card, game_number),
              reason: error_message
            )
          )
        end

        def build_error_message_of_game_status_if_needed(aggregate_store, game_number)
          error_message = nil
          error_message ||= '指定されたゲームが存在しません' unless Event.exists_game?(game_number)
          error_message ||= 'ゲームが進行中ではありません' unless aggregate_store.game_in_progress?
          error_message
        end

        def build_error_message_of_hand_state_in_hand_if_needed(aggregate_store, discarded_card, board, _game_number)
          return 'デッキの残り枚数が不足しています' unless board.drawable?

          events = aggregate_store.load_all_events_in_order
          rebuilt_hand = events.reduce([]) { |acc, event| rebuild_hand_from_event(acc, event, board) }

          return '交換対象のカードが手札に存在しません' unless rebuilt_hand.include?(discarded_card)

          nil
        end

        def rebuild_hand_from_event(hand, event, board)
          if event.is_a?(GameStartedEvent)
            hand = event.to_event_data[:initial_hand].map do |c|
              HandSet.build_card_for_command(c.is_a?(HandSet::Card) ? c.to_s : c)
            end
          elsif event.is_a?(CardExchangedEvent)
            hand = board.build_cards_from_exchanged_event(hand, event)
          end
          hand
        end
      end
    end
  end
end
