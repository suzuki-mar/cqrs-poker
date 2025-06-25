# frozen_string_literal: true

class Simulator
  attr_reader :failure_handled

  def initialize(logger)
    @log_writer = LogWriter.new(logger)
    @failure_handled = false
  end

  def run(command_bus)
    @command_bus = command_bus
    command_bus.execute(Commands::GameStart.new)
  end

  def handle_event(event)
    log_writer.event_processed(event.class.name)

    if event.is_a?(GameStartedEvent)
      query_service = QueryService.new(event.game_number)
      hand_set = query_service.player_hand_set
      log_writer.initial_hand(hand_set)
    end

    next_command = determine_next_command(event)
    command_bus.execute(next_command) if next_command
  end

  def handle_failure(error)
    @failure_handled = true
    log_writer.command_failure_handled(error.message) if error
  end

  private

  attr_reader :log_writer, :command_bus

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
