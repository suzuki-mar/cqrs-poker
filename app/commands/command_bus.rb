class CommandBus
  def initialize(event_bus, logger)
    @event_bus = event_bus
    @logger = logger
  end

  def execute(command)
    handler = if command.is_a?(Commands::GameStart)
                CommandHandlers::GameStart.new(event_bus)
              else
                CommandHandlers::InGame.new(event_bus)
              end

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
      logger.warn "[警告] コマンド失敗: #{error.message}"
    when CommandErrors::VersionConflict
      logger.warn '[警告] コマンド失敗: バージョン競合'
    end
  end
end
