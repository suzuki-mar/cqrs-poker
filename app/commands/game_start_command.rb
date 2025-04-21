# frozen_string_literal: true

class GameStartCommand
  def execute(deck)
    if EventStoreHolder.new.game_already_started?
      raise InvalidCommand, "ゲームはすでに開始されています"
    end

    deck.draw_initial_hand
  end
end
