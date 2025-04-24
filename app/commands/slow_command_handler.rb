# frozen_string_literal: true

class SlowCommandHandler < CommandHandler
  def initialize(event_bus, delay: 1)
    super(event_bus)
    @delay = delay
  end

  def handle(command, context)
    sleep(@delay)
    super(command, context)
  end

  private

  attr_reader :delay
end
