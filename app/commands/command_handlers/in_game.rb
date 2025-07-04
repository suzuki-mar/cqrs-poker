# frozen_string_literal: true

module CommandHandlers
  class InGame
    def initialize(event_bus)
      @event_bus = event_bus
      @aggregate_store = Aggregates::Store.new
    end

    # メソッド分割をしているため今の状態のほうがコードが見やすいため
    # rubocop:disable Metrics/MethodLength
    def handle(command)
      @command = cast_to_in_game_command(command)

      @executor = build_executor

      board = load_board

      error = build_error_result(board)
      return error if error

      executor.operate_board(board)

      result = append_event_to_store!
      return result if result.error

      result.event or raise '不正な実行結果'

      event_bus.publish(result.event)
      result
    end
    # rubocop:enable Metrics/MethodLength

    private

    attr_reader :event_bus, :aggregate_store, :command, :executor

    def build_executor
      return InGameExecutor::EndGame.new if @command.is_a?(Commands::EndGame)
      return InGameExecutor::ExchangeCard.new if @command.is_a?(Commands::ExchangeCard)

      raise ArgumentError, "不正なコマンドです #{@command}"
    end

    def append_event_to_store!
      event = executor.build_event(@command)
      aggregate_store.append_event(event, @command.game_number)
    end

    def load_board
      game_number = @command.game_number or raise "不正なコマンドです #{@command}"
      aggregate_store.load_board_aggregate_for_current_state(game_number)
    end

    def build_error_result(board)
      ErrorResultBuilder.build_error_if_needed(
        @command, board, aggregate_store
      )
    end

    def cast_to_in_game_command(command)
      case command
      when Commands::ExchangeCard, Commands::EndGame
        command
      else
        raise '不正なコマンドです'
      end
    end
  end
end
