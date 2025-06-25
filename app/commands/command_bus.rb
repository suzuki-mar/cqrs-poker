class CommandBus
  def initialize(event_bus, failure_handler)
    @event_bus = event_bus
    @failure_handler = failure_handler
  end

  def execute(command)
    handler = build_handler(command)

    result = handler.handle(command)
    handle_failure_if_needed(result)

    result
  end

  private

  attr_reader :event_bus, :failure_handler

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
  end
end
