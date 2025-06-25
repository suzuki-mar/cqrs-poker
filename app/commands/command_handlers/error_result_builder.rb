# frozen_string_literal: true

module CommandHandlers
  class ErrorResultBuilder
    class << self
      def build_error_if_needed(command, board, aggregate_store)
        error_code = build_error_code_of_game_status_if_needed(command, board, aggregate_store)
        return build_result(command, error_code) if error_code

        return nil unless command.is_a?(Commands::ExchangeCard)

        return build_result(command, CommandErrors::InvalidCommand::NO_CARDS_LEFT) unless board.drawable?

        error_code = build_card_not_found_error_code_if_needed(command, board, aggregate_store)
        return build_result(command, error_code) if error_code

        nil
      end

      def build_result(command, error_code)
        raise_if_invalid_error_code(error_code)
        error = CommandErrors::InvalidCommand.new(command: command, error_code: error_code)
        CommandResult.new(error: error)
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

      private

      def build_error_code_of_game_status_if_needed(_command, board, _aggregate_store)
        return CommandErrors::InvalidCommand::GAME_NOT_FOUND unless board.exists_game?
        return CommandErrors::InvalidCommand::GAME_ALREADY_ENDED if board.game_ended?
        return CommandErrors::InvalidCommand::GAME_NOT_IN_PROGRESS unless board.game_in_progress?

        nil
      end

      def build_card_not_found_error_code_if_needed(command, board, aggregate_store)
        events = aggregate_store.load_all_events_in_order(command.game_number)
        # @type var rebuilt_hand: Array[HandSet::Card]
        rebuilt_hand = []
        events.each { |event| rebuilt_hand = rebuild_hand_from_event(board, rebuilt_hand, event) }
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
    end
  end
end
