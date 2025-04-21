# frozen_string_literal: true

class ExchangeCardCommand
  def initialize(payload)
    @payload = payload
  end

  def execute(deck)
    deck.exchange(payload[:discarded_card])
  end

  private

  attr_reader :payload
end
