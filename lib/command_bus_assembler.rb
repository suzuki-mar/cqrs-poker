# frozen_string_literal: true

# CommandBusとその依存関係を組み立てる責務を持つクラス
class CommandBusAssembler
  def self.build(event_publishers: nil, failure_handler: nil, simulator: nil)
    new(event_publishers, failure_handler, simulator).build
  end

  private_class_method :new

  def initialize(event_publishers, failure_handler, simulator)
    @simulator = simulator

    @event_publishers = event_publishers || build_default_publishers
    @failure_handler = failure_handler || @simulator
  end

  # 全ての依存関係が解決されたCommandBusインスタンスを構築して返す
  def build
    event_bus = EventBus.new(event_publishers)
    CommandBus.new(event_bus, failure_handler)
  end

  private

  def build_default_publishers
    projection = EventListener::Projection.new
    # @type var listeners: Array[_EventSubscriber]
    listeners = []
    listeners << simulator if simulator

    event_publisher = EventPublisher.new(
      projection: projection,
      event_listeners: listeners
    )

    [event_publisher]
  end

  attr_reader :event_publishers, :failure_handler, :simulator
end
