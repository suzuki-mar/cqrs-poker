# frozen_string_literal: true

class Simulator
  def initialize(command_bus)
    @command_bus = command_bus
    @completed_events = []
  end

  def start
    game_start_command = Commands::GameStart.new
    result = @command_bus.execute(game_start_command)

    # エラーハンドリング（エラーがある場合はログ出力）
    Rails.logger.error "ゲーム開始に失敗しました: #{result.error}" if result.failure?

    result
  end

  def completed_events
    @completed_events.dup
  end

  def handle_event(event)
    @completed_events << event
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

  private

  attr_reader :command_bus
end
