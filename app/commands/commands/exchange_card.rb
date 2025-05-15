# frozen_string_literal: true

module Commands
  class ExchangeCard
    attr_reader :discarded_card, :game_number

    def initialize(discarded_card, game_number)
      @discarded_card = discarded_card
      @game_number = game_number
    end
  end
end
