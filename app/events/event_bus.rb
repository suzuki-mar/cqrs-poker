# frozen_string_literal: true

class EventBus
  def initialize(publishers)
    @publishers = publishers
  end

  def publish(event)
    Rails.logger.info "Event published: #{event.class.name}"
    @publishers.each do |publisher|
      publisher.broadcast(:handle_event, event)
    end
  end

  private

  attr_reader :publishers
end
