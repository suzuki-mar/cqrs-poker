# frozen_string_literal: true

class EventPublisher
  include Wisper::Publisher

  def initialize(projection:, event_listener:)
    @projection = projection
    @event_listener = event_listener
    @published_events = []
    subscribe(projection)
    subscribe(event_listener)
  end

  def broadcast(event_name, *args)
    @published_events << args.first
    super
  end

  # NOTE: EventBusからイベントを発行できるようにするためpublicにしています
  public :broadcast

  attr_reader :published_events

  private

  attr_reader :projection, :event_listener
end
