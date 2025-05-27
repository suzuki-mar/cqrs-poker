# frozen_string_literal: true

module CommandHandlers
  module InGameExecutor
    class EndGame
      def operate_board(board)
        board.finish_game
      end

      def build_event(_command)
        GameEndedEvent.new(Time.current)
      end
    end
  end
end
