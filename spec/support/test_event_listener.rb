# frozen_string_literal: true

class TestEventListener
  attr_reader :received_events

  def initialize
    @received_events = []
  end

  def handle_event(event)
    @received_events << event
    Rails.logger.info "Event received: #{event.class.name}"
  end

  def clear
    @received_events = []
  end
end
