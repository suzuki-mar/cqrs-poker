# frozen_string_literal: true

module HandlerStrategy
  class GameStart
    def initialize(command, context, board)
      @command = command
      @context = context
      @board = board
    end

    def build_invalid_command_event_if_needed
      if board.respond_to?(:game_already_started?) && board.game_already_started?
        return InvalidCommandEvent.new(command: command, reason: "ゲームはすでに開始されています")
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
