# frozen_string_literal: true

module CommandHandlers
  module InGameExecutor
    class ExchangeCard
      def operate_board(board)
        @new_card = board.draw
      end

      def build_event(command)
        raise "不正なコマンドです#{command}" unless command.is_a?(Commands::ExchangeCard)

        exchange_command = command

        CardExchangedEvent.new(exchange_command.discarded_card, new_card)
      end

      private

      attr_reader :new_card
    end
  end
end
