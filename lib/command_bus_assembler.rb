# frozen_string_literal: true

# CommandBusとその依存関係を組み立てる責務を持つクラス
class CommandBusAssembler
  def self.build(logger: nil, event_publishers: nil, failure_handler: nil, simulator: nil)
    new(logger, event_publishers, failure_handler, simulator).build
  end

  private_class_method :new

  def initialize(logger, event_publishers, failure_handler, simulator)
    @logger = logger || ::Logger.new($stdout)
    @simulator = simulator

    @event_publishers = event_publishers || build_default_publishers
    @failure_handler = failure_handler || @simulator
  end

  # 全ての依存関係が解決されたCommandBusインスタンスを構築して返す
  def build
    event_bus = EventBus.new(event_publishers)
    CommandBus.new(logger, event_bus, failure_handler)
  end

  private

  def build_default_publishers
    projection = EventListener::Projection.new
    # @type var other_listeners: Array[_EventSubscriber]
    other_listeners = [EventListener::Log.new(logger)]
    other_listeners << simulator if simulator

    event_publisher = EventPublisher.new(
      projection: projection,
      event_listeners: other_listeners
    )

    [event_publisher]
  end

  attr_reader :logger, :event_publishers, :failure_handler, :simulator
end
