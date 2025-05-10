# frozen_string_literal: true

# バージョン競合は全コマンドで発生しうるため、ユースケースごとに同じ観点でテストをまとめて管理しています。
# - テストの重複や分散を避け、運用・保守の効率を高めるため
# - どのコマンドでも「バージョン競合時の正しいエラー応答・ログ出力」が保証される
# - 新しいユースケース追加時も、このファイルに追記するだけで網羅的な検証が可能です

require 'rails_helper'

def __inject_slow_handler_into_command_bus(command_bus:, event_bus:, handler_key:, handler_class:, delay: 0.5)
  # テスト専用: 任意のコマンドバスのハンドラーを遅延付きハンドラーに差し替える
  command_bus.instance_variable_set(
    handler_key,
    SlowCommandHandler.new(handler_class.new(event_bus), delay: delay)
  )
end

# shared_examplesを使用すると何らかの理由で処理が停止するのでメソッドを使用している
def __run_concurrent_commands(command_bus, command, context, thread_count: 2)
  results = []
  threads = Array.new(thread_count) do
    Thread.new do
      results << command_bus.execute(command, context)
    end
  end
  threads.each(&:join)
  results
end

RSpec.describe 'バージョン競合ユースケース' do
  let(:logger) { TestLogger.new }
  let!(:command_bus) { UseCaseHelper.build_command_bus(logger) }
  let(:player_hand_state) { ReadModels::PlayerHandState.new }
  let(:event_publisher) { EventPublisher.new(projection: Projection.new, event_listener: LogEventListener.new(logger)) }
  let(:event_bus) { EventBus.new(event_publisher) }

  describe 'カード交換時のバージョン競合' do
    before do
      # まずゲームを開始してセッションを作成
      command_bus.execute(Command.new, CommandContext.build_for_game_start)
      # 任意のハンドラーを遅延付きで差し替え
      __inject_slow_handler_into_command_bus(
        command_bus: command_bus,
        event_bus: event_bus,
        handler_key: :@exchange_card_handler,
        handler_class: CommandHandlers::ExchangeCard,
        delay: 0.5
      )
    end

    subject do
      card = player_hand_state.refreshed_hand_set.cards.first
      context = CommandContext.build_for_exchange(card)
      __run_concurrent_commands(command_bus, Command.new, context)
    end

    it '並行実行でバージョン競合が発生し、警告ログが出力されること' do
      results = subject
      success_results = results.select(&:success?)
      error_results = results.select(&:failure?)

      expect(success_results.size).to eq(1)
      expect(error_results.size).to eq(1)

      expect(success_results.first.event).to be_a(CardExchangedEvent)
      expect(error_results.first.error).to be_a(CommandErrors::VersionConflict)
      expect(logger.messages_for_level(:warn).last).to match(/コマンド失敗: バージョン競合/)
    end
  end

  describe 'ゲーム開始時のバージョン競合' do
    before do
      __inject_slow_handler_into_command_bus(
        command_bus: command_bus,
        event_bus: event_bus,
        handler_key: :@game_start_handler,
        handler_class: CommandHandlers::GameStart,
        delay: 0.5
      )
    end

    subject do
      command = Command.new
      context = CommandContext.build_for_game_start
      __run_concurrent_commands(command_bus, command, context)
    end

    it '並行実行でバージョン競合が発生し、警告ログが出力されること' do
      results = subject
      success_results = results.select(&:success?)
      error_results = results.select(&:failure?)

      expect(success_results.size).to eq(1)
      expect(error_results.size).to eq(1)

      expect(success_results.first.event).to be_a(GameStartedEvent)
      expect(error_results.first.error).to be_a(CommandErrors::VersionConflict)
      expect(logger.messages_for_level(:warn).last).to match(/コマンド失敗: バージョン競合/)
    end
  end

  describe 'ゲーム終了時のバージョン競合' do
    before do
      # まずゲームを開始してセッションを作成
      command_bus.execute(Command.new, CommandContext.build_for_game_start)
      # EndGame用の遅延付きハンドラーを差し替え
      __inject_slow_handler_into_command_bus(
        command_bus: command_bus,
        event_bus: event_bus,
        handler_key: :@end_game_handler,
        handler_class: CommandHandlers::EndGame,
        delay: 0.5
      )
    end

    subject do
      context = CommandContext.build_for_end_game
      __run_concurrent_commands(command_bus, Command.new, context)
    end

    it '並行実行でバージョン競合が発生し、警告ログが出力されること' do
      results = subject
      success_results = results.select(&:success?)
      error_results = results.select(&:failure?)

      expect(success_results.size).to eq(1)
      expect(error_results.size).to eq(1)

      expect(success_results.first.event).to be_a(GameEndedEvent)
      expect(error_results.first.error).to be_a(CommandErrors::VersionConflict)
      expect(logger.messages_for_level(:warn).last).to match(/コマンド失敗: バージョン競合/)
    end

    it 'すでに終了している場合はエラーになること' do
      # 1回目の終了（正常）
      command_bus.execute(Command.new, CommandContext.build_for_end_game)
      # 2回目の終了（異常）
      result = command_bus.execute(Command.new, CommandContext.build_for_end_game)
      expect(result.error).to be_a(CommandErrors::InvalidCommand)
      expect(result.error.reason).to eq('ゲームが進行中ではありません')
    end
  end

  # 今後、他ユースケースのバージョン競合テストもここに追加可能
end
