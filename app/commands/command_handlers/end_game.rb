# frozen_string_literal: true

module CommandHandlers
  class EndGame
    def initialize(event_bus)
      @event_bus = event_bus
      @aggregate_store = Aggregates::Store.new
    end

    def handle(command)
      raise ArgumentError, 'game_numberがnilです' if command.game_number.nil?

      game_number = command.game_number

      error_result = build_error_result_if_needed(command, game_number)
      return error_result if error_result

      board = aggregate_store.load_board_aggregate_for_current_state
      board.finish_game

      result = append_event_to_store!(command, game_number)
      return result if result.error

      event_bus.publish(result.event)
      result
    end

    private

    attr_reader :event_bus, :aggregate_store

    def append_event_to_store!(_command, game_number)
      # ゲーム終了時のドメイン操作が必要ならここで直接呼ぶ
      event = GameEndedEvent.new

      aggregate_store.append_event(event, game_number)
    end

    def build_error_result_if_needed(command, game_number)
      if Event.exists?(game_number: game_number.value, event_type: GameEndedEvent.event_type)
        return CommandResult.invalid_command(command, 'すでにゲームが終了しています')
      end

      return CommandResult.invalid_command(command, 'ゲームが進行中ではありません') unless aggregate_store.game_in_progress?

      return CommandResult.invalid_command(command, '指定されたゲームが存在しません') unless Event.exists_game?(game_number)

      nil
    end
  end
end
