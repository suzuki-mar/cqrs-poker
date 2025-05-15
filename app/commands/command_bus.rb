class CommandBus
  def initialize(event_bus, logger)
    @event_bus = event_bus
    @logger = logger
  end

  def execute(command)
    handler = build_handler_map[command.class]
    raise ArgumentError, "未知のコマンドクラスです: #{command.class}" unless handler

    result = handler.handle(command)
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
      GameStartCommand => CommandHandlers::GameStart.new(event_bus),
      EndGameCommand => CommandHandlers::EndGame.new(event_bus),
      ExchangeCardCommand => CommandHandlers::ExchangeCard.new(event_bus)
    }
  end
end
