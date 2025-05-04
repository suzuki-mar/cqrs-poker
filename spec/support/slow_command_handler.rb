# frozen_string_literal: true

# テスト専用のコマンドハンドラーラッパー
# - 任意のコマンドハンドラーに遅延（sleep）を挟むことで、並行処理やタイミング依存のテストを行いたい場合に利用
# - 本番用のCommandHandlerは即時実行だが、テストで意図的に遅延させたいときに必要
class SlowCommandHandler
  def initialize(handler, delay: 1)
    @handler = handler
    @delay = delay
  end

  def handle(command, context)
    sleep(@delay)
    @handler.handle(command, context)
  end

  private

  attr_reader :handler, :delay
end
