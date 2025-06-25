# frozen_string_literal: true

class Simulator
  attr_reader :event_handled, :failure_handled

  def initialize
    @event_handled = false
    @failure_handled = false
  end

  def run(command)
    @command_bus.execute(command)
  end

  def handle_event(event)
    @event_handled = true
    Rails.logger.info "Simulator: イベントが完了しました - #{event.class.name}"

    # 特定のイベントに対する追加処理があればここに記述
    case event
    when GameStartedEvent
      Rails.logger.info 'Simulator: ゲームが開始されました'
    when CardExchangedEvent
      Rails.logger.info 'Simulator: カードが交換されました'
    when GameEndedEvent
      Rails.logger.info 'Simulator: ゲームが終了しました'
    end
  end

  def handle_failure(error)
    @failure_handled = true
    # ここでコマンド失敗時の共通処理を定義できる
    Rails.logger.error "[HANDLER] コマンド失敗がハンドルされました: #{error.message}" if error
  end

  private

  attr_reader :command_bus
end
