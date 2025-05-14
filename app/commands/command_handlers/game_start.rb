# frozen_string_literal: true

module CommandHandlers
  class GameStart
    def initialize(event_bus)
      @event_bus = event_bus
      @aggregate_store = Aggregates::Store.new
    end

    def handle(command, context)
      @command = command

      raise ArgumentError, 'このハンドラーはGAME_START専用です' unless context.type == CommandContext::Types::GAME_START

      error_result = build_already_started_error_result
      return error_result if error_result

      result = append_event_to_store!
      return result if result.error

      event_bus.publish(result.event)
      result
    end

    private

    attr_reader :event_bus, :aggregate_store, :command

    def build_already_started_error_result
      return unless aggregate_store.game_in_progress?

      CommandResult.new(
        error: CommandErrors::InvalidCommand.new(
          command: command,
          reason: 'すでにゲームが開始されています'
        )
      )
    end

    def append_event_to_store!
      board = Aggregates::BoardAggregate.load_for_current_state
      initial_hand = command.execute_for_game_start(board)
      event = GameStartedEvent.new(initial_hand)
      game_number = GameNumber.build

      aggregate_store.append_initial_event(event, game_number)
    end
  end
end
