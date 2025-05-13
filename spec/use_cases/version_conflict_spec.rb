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

# バージョン競合を強制するテスト用ヘルパー
# usage: __force_version_conflict

def __force_version_conflict
  allow_any_instance_of(Aggregates::Store).to receive(:current_version).and_return(0)
end

RSpec.describe 'バージョン競合ユースケース' do
  let(:logger) { TestLogger.new }
  let!(:command_bus) { UseCaseHelper.build_command_bus(logger) }
  let(:player_hand_state) { ReadModels::PlayerHandState.new }
  let(:event_publisher) { EventPublisher.new(projection: Projection.new, event_listener: LogEventListener.new(logger)) }
  let(:event_bus) { EventBus.new(event_publisher) }

  describe 'カード交換時のバージョン競合' do
    before do
      command_bus.execute(Command.new, CommandContext.build_for_game_start)
    end

    it '警告ログが出力されること' do
      __force_version_conflict
      card = ReadModels::PlayerHandState.new.refreshed_hand_set.cards.first
      context = CommandContext.build_for_exchange(card)
      result = command_bus.execute(Command.new, context)
      expect(result.error).to be_a(CommandErrors::VersionConflict)
      expect(logger.messages_for_level(:warn).last).to match(/コマンド失敗: バージョン競合/)
    end
  end

  # 今後、他ユースケースのバージョン競合テストもここに追加可能
end
