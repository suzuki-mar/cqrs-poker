# frozen_string_literal: true

class Simulator
  attr_reader :failure_handled

  def initialize(logger)
    @logger = logger
    @failure_handled = false
  end

  # シミュレーションを開始する
  def run(command_bus)
    @command_bus = command_bus
    @command_bus.execute(Commands::GameStart.new)
  end

  def handle_event(event)
    @logger.info "Simulator: イベント[#{event.class.name}]を処理しました。"

    next_command = determine_next_command(event)
    @command_bus.execute(next_command) if next_command
  end

  def handle_failure(error)
    @failure_handled = true
    @logger.error "[HANDLER] コマンド失敗がハンドルされました: #{error.message}" if error
  end

  private

  def determine_next_command(event)
    case event
    when GameStartedEvent
      query_service = QueryService.new(event.game_number)
      card_to_discard = query_service.player_hand_set.cards.first
      Commands::ExchangeCard.new(card_to_discard, event.game_number)
    when CardExchangedEvent
      Commands::EndGame.new(event.game_number)
    when GameEndedEvent
      # ゲームが終了したら、シミュレーションを停止する (次のコマンドは発行しない)
      nil
    end
  end
end
