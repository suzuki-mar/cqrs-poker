# frozen_string_literal: true

class CommandHandler
  def initialize(event_store_domain:)
    @event_store_domain = event_store_domain
  end

  def handle(params)
    GameStartCommand.new(event_store_domain: @event_store_domain).execute
  end
end
