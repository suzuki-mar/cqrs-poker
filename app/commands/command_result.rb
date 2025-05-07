# frozen_string_literal: true

class CommandResult
  attr_reader :event, :error

  def initialize(event: nil, error: nil)
    @event = event
    @error = error
  end

  def success?
    !event.nil?
  end

  def failure?
    !error.nil?
  end
end
