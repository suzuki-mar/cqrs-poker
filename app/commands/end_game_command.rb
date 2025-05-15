# frozen_string_literal: true

class EndGameCommand
  attr_reader :game_number

  def initialize(game_number)
    @game_number = game_number
  end
end
