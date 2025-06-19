module CommandHandlers
  class ErrorResultBuilder
    class << self
      def build_error_if_needed(command, board, aggregate_store)
        error_code = build_error_code_of_game_status_if_needed(command, board, aggregate_store)

        if error_code.nil? && command.is_a?(Commands::ExchangeCard)
          error_code = build_card_not_found_error_code_if_needed(command, board, aggregate_store)
        end

        return nil if error_code.nil?

        # @type var game_state_error_code: game_state_invalid_command
        game_state_error_code = error_code
        raise_if_invalid_error_code(game_state_error_code)

        error = CommandErrors::InvalidCommand.new(
          command: command, error_code: error_code
        )

        CommandResult.new(error: error)
      end

      private

      def build_error_code_of_game_status_if_needed(_command, board, _aggregate_store)
        return CommandErrors::InvalidCommand::GAME_NOT_FOUND unless board.exists_game?

        return CommandErrors::InvalidCommand::GAME_ALREADY_ENDED if board.game_ended?

        return CommandErrors::InvalidCommand::GAME_NOT_IN_PROGRESS unless board.game_in_progress?
        return CommandErrors::InvalidCommand::NO_CARDS_LEFT unless board.drawable?

        nil
      end

      def build_card_not_found_error_code_if_needed(command, board, aggregate_store)
        events = aggregate_store.load_all_events_in_order(command.game_number)
        rebuilt_hand = events.reduce([]) { |acc, event| rebuild_hand_from_event(board, acc, event) }
        return CommandErrors::InvalidCommand::CARD_NOT_FOUND unless rebuilt_hand.include?(command.discarded_card)

        nil
      end

      def rebuild_hand_from_event(_board, hand, event)
        return hand unless event.is_a?(GameStartedEvent) || event.is_a?(CardExchangedEvent)

        return Aggregates::BuildCards.from_exchanged_event(hand, event) if event.is_a?(CardExchangedEvent)

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
