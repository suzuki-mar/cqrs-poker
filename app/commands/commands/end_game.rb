# frozen_string_literal: true

module Commands
  class EndGame
    attr_reader :game_number

    def initialize(game_number)
      @game_number = game_number
    end
  end
end
