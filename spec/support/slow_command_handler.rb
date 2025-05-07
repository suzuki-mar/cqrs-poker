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
    # 元のハンドラーを呼び出す前に遅延を入れる
    sleep(@delay)
    handler.handle(command, context)
  end

  private

  attr_reader :handler, :delay

  def method_missing(method_name, *, &)
    if handler.respond_to?(method_name, true)
      handler.send(method_name, *, &)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    handler.respond_to?(method_name, include_private) || super
  end
end
