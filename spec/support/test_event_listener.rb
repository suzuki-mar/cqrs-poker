# frozen_string_literal: true

# テスト専用のイベントリスナー
# - 受信したイベントを配列（received_events）に記録する
# - テストで「どんなイベントが発行されたか」を明示的に検証したい場合に利用
# - 本番用リスナー（LogEventListener等）は履歴を持たないため、テストでの履歴検証用途で必要
class TestEventListener
  attr_reader :received_events

  def initialize
    @received_events = []
  end

  def handle_event(event)
    @received_events << event
    Rails.logger.info "Event received: #{event.class.name}"
  end

  def clear
    @received_events = []
  end
end
