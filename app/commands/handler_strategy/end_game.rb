# frozen_string_literal: true

module HandlerStrategy
  class EndGame
    def initialize(command, context, board, aggregate_store)
      @command = command
      @context = context
      @board = board
      @aggregate_store = aggregate_store
    end

    def build_invalid_command_event_if_needed
      unless aggregate_store.game_already_started?
        return InvalidCommandEvent.new(command: command, reason: 'ゲームが開始されていません')
      end

      nil
    end

    def build_event_by_executing
      command.execute_for_end_game(board)
      GameEndedEvent.new
    end

    private

    attr_reader :command, :context, :board, :aggregate_store
  end
end
