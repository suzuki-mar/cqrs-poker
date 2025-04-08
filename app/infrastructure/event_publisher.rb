# frozen_string_literal: true

class EventPublisher
  include Wisper::Publisher

  # NOTE: EventBusからイベントを発行できるようにするためpublicにしています
  public :broadcast
end
