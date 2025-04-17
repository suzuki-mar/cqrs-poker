# frozen_string_literal: true

class GameStartCommand
  def execute(deck)
    raise InvalidCommand, "ゲームはすでに開始されています" if GameState.exists?(status: :started)

    initial_hand = deck.draw_initial_hand
    game_state = GameState.new(status: :started)
    game_state.assign_hand_number_from_set(initial_hand)
    game_state.save!

    GameStartedEvent.new(initial_hand)
  end
end
