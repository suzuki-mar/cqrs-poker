class CommandBus
  def initialize(event_bus, logger)
    @event_bus = event_bus
    @logger = logger
  end

  def execute(command, context)
    handler = build_handler_map[context.type]
    raise ArgumentError, "未知のコマンドタイプです: #{context.type}" unless handler

    result = handler.handle(command, context)
    log_error_if_needed(result.error)
    result
  end

  private

  attr_reader :event_bus, :logger

  def log_error_if_needed(error)
    case error
    when CommandErrors::InvalidCommand
      logger.warn "[警告] コマンド失敗: #{error.reason}"
    when CommandErrors::VersionConflict
      logger.warn '[警告] コマンド失敗: バージョン競合'
    end
  end

  def build_handler_map
    {
      CommandContext::Types::GAME_START => CommandHandlers::GameStart.new(event_bus),
      CommandContext::Types::EXCHANGE_CARD => CommandHandlers::ExchangeCard.new(event_bus),
      CommandContext::Types::END_GAME => CommandHandlers::EndGame.new(event_bus)
    }
  end
end
