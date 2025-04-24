# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommandHandler do
  let(:event_publisher) do
    EventPublisher.new(
      projection: Projection.new,
      event_listener: LogEventListener.new(TestLogger.new)
    )
  end

  let(:event_bus) { EventBus.new(event_publisher) }
  let(:command_handler) { described_class.new(event_bus) }

  describe "#handle" do
    it "コマンドを実行し、イベントを発行できること" do
      allow(event_publisher).to receive(:broadcast)

      event = command_handler.handle(Command.new, CommandContext.build_for_game_start)

      expect(event).to be_a(GameStartedEvent)
      expect(event_publisher).to have_received(:broadcast)
    end
  end

  context '遅延コマンドハンドラーによるバージョン競合' do
    it '遅延したコマンドがバージョン競合で失敗し、例外ではなくエラーオブジェクトを返す' do
      slow_handler = SlowCommandHandler.new(event_bus, delay: 0.5)
      normal_handler = CommandHandler.new(event_bus)

      command1 = Command.new
      command2 = Command.new
      context = CommandContext.build_for_game_start

      # slow_handlerで1回目を遅延実行（スレッドで並列実行）
      thread = Thread.new { slow_handler.handle(command1, context) }

      # すぐに2回目を実行して状態を進める
      sleep(0.1)
      normal_handler.handle(command2, context)

      # 遅延していた1回目の結果を取得
      result1 = thread.value

      # ここでresult1がバージョン競合エラーであることを検証（仮の例）
      expect(result1).to be_a(VersionConflictEvent)
      # 実際の競合判定は実装に合わせて修正してください
    end
  end
end
