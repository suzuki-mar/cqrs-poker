module CommandHandlers
  class ErrorResultBuilder
    class << self
      def build_error_if_needed(command, aggregate_store, board)
        error_code = build_error_code_of_game_status_if_needed(aggregate_store, command, board)

        if error_code.nil? && command.is_a?(Commands::ExchangeCard)
          error_code = build_card_not_found_error_code_if_needed(aggregate_store, board, command)
        end

        return nil if error_code.nil?

        raise_if_invalid_error_code(error_code)

        error = CommandErrors::InvalidCommand.new(
          command: command, error_code: error_code
        )

        CommandResult.new(error: error)
      end

      private

      def build_error_code_of_game_status_if_needed(aggregate_store, command, board)
        game_number = command.game_number or raise "#{command} game_numberが未設定です"

        return CommandErrors::InvalidCommand::GAME_NOT_FOUND unless aggregate_store.exists_game?(game_number)

        return CommandErrors::InvalidCommand::GAME_ALREADY_ENDED if aggregate_store.game_ended?(game_number)

        return CommandErrors::InvalidCommand::GAME_NOT_IN_PROGRESS unless aggregate_store.game_in_progress?(game_number)
        return CommandErrors::InvalidCommand::NO_CARDS_LEFT unless board.drawable?

        nil
      end

      def build_card_not_found_error_code_if_needed(aggregate_store, board, command)
        events = aggregate_store.load_all_events_in_order
        rebuilt_hand = events.reduce([]) { |acc, event| rebuild_hand_from_event(acc, event, board) }
        return CommandErrors::InvalidCommand::CARD_NOT_FOUND unless rebuilt_hand.include?(command.discarded_card)

        nil
      end

      def rebuild_hand_from_event(hand, event, board)
        return hand unless event.is_a?(GameStartedEvent) || event.is_a?(CardExchangedEvent)

        return board.build_cards_from_exchanged_event(hand, event) if event.is_a?(CardExchangedEvent)

        event.to_event_data[:initial_hand].map do |c|
          c.is_a?(HandSet::Card) ? c : HandSet.build_card(c.to_s)
        end
      end

      def raise_if_invalid_error_code(error_code)
        valid_error_codes = [
          CommandErrors::InvalidCommand::GAME_NOT_FOUND,
          CommandErrors::InvalidCommand::GAME_NOT_IN_PROGRESS,
          CommandErrors::InvalidCommand::NO_CARDS_LEFT,
          CommandErrors::InvalidCommand::CARD_NOT_FOUND,
          CommandErrors::InvalidCommand::GAME_ALREADY_ENDED
        ]

        raise "不正なエラーコード #{error_code}" unless valid_error_codes.include?(error_code)
      end
    end
  end
end
