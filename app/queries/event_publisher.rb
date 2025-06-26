# frozen_string_literal: true

class EventPublisher
  include Wisper::Publisher

  def initialize(projection:, event_listeners:)
    @projection = projection
    @event_listeners = event_listeners
    @published_events = []
    subscribe(projection)
    event_listeners.each do |listener|
      subscribe(listener)
    end
  end

  def broadcast(event_name, *args)
    @published_events << args.first
    super
  end

  # NOTE: EventBusからイベントを発行できるようにするためpublicにしています
  public :broadcast

  attr_reader :published_events

  private

  attr_reader :projection, :event_listeners
end
