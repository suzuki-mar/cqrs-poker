# frozen_string_literal: true

module HandlerStrategy
  class GameStart
    def initialize(command, context, board, aggregate_store)
      @command = command
      @context = context
      @board = board
      @aggregate_store = aggregate_store
    end

    def build_invalid_command_event_if_needed
      if aggregate_store.game_in_progress?
        return FailureEvents::InvalidCommand.new(command: command, reason: 'already_started')
      end

      nil
    end

    def build_event_by_executing
      initial_hand = command.execute_for_game_start(board)
      SuccessEvents::GameStarted.new(initial_hand)
    end

    private

    attr_reader :command, :context, :board, :aggregate_store
  end
end
