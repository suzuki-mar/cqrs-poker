# frozen_string_literal: true

class GameStartCommand
  def execute(deck)
    # TODO: GameStateへの依存を削除し、EventStoreを使用して状態チェックを行うように修正する
    # CQRSの原則に従い、Command側でReadModelを参照しない
    raise InvalidCommand, "ゲームはすでに開始されています" if GameState.exists?(status: :started)

    initial_hand = deck.draw_initial_hand
    # TODO: ReadModelの更新はProjectionで行うように修正する
    game_state = GameState.new(status: :started)
    game_state.assign_hand_number_from_set(initial_hand)
    game_state.save!

    initial_hand
  end
end
