# frozen_string_literal: true

module HandlerStrategy
  class GameStart
    def initialize(command, context, board)
      @command = command
      @context = context
      @board = board
    end

    def build_invalid_command_event_if_needed
      if board.game_already_started?
        reason = { message: 'すでにゲームが開始されているためゲームを開始できませんでした' }
        return VersionConflictEvent.new(
          GameStartedEvent::EVENT_TYPE,
          1,
          reason
        )
      end
      nil
    end

    def build_event_by_executing
      initial_hand = command.execute_for_game_start(board)
      GameStartedEvent.new(initial_hand)
    end

    private

    attr_reader :command, :context, :board
  end
end
