class CommandBus
  def initialize(logger, event_bus, failure_handler)
    @event_bus = event_bus
    @logger = logger
    @failure_handler = failure_handler
  end

  def execute(command)
    handler = build_handler(command)

    result = handler.handle(command)
    handle_failure_if_needed(result)

    result
  end

  private

  attr_reader :event_bus, :logger, :failure_handler

  def log_error_if_needed(error)
    case error
    when CommandErrors::InvalidCommand
      logger.warn "[警告] コマンド失敗: #{error.message}"
    when CommandErrors::VersionConflict
      logger.warn '[警告] コマンド失敗: バージョン競合'
    end
  end

  def build_handler(command)
    handler = if command.is_a?(Commands::GameStart)
                CommandHandlers::GameStart.new(event_bus)
              else
                CommandHandlers::InGame.new(event_bus)
              end

    raise ArgumentError, "未知のコマンドクラスです: #{command.class}" unless handler

    handler
  end

  def handle_failure_if_needed(result)
    return unless result.failure?

    error = result.error
    return unless error

    failure_handler&.handle_failure(error)
    log_error_if_needed(error)
  end
end
