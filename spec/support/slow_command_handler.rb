# frozen_string_literal: true

# テスト専用のコマンドハンドラー
# - コマンド処理に任意の遅延（sleep）を挟むことで、並行処理やタイミング依存のテストを行いたい場合に利用
# - 本番用のCommandHandlerは即時実行だが、テストで意図的に遅延させたいときに必要
class SlowCommandHandler < CommandHandlers::GameStart
  def initialize(event_bus, delay: 1)
    super(event_bus)
    @delay = delay
  end

  def handle(command, context)
    sleep(@delay)
    super
  end

  private

  attr_reader :delay
end
