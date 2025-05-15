# frozen_string_literal: true

class ExchangeCardCommand
  attr_reader :discarded_card, :game_number

  def initialize(discarded_card, game_number)
    @discarded_card = discarded_card
    @game_number = game_number
  end
end
