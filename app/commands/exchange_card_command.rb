# frozen_string_literal: true

class ExchangeCardCommand
  def execute(board, discarded_card)
    board.exchange(discarded_card)
  end
end
