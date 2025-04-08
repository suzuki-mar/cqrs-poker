class GameStateDomain
  def initialize(game_state)
    @game_state = game_state
  end

  def start_game(initial_hand)
    @game_state.update!(initial_hand: initial_hand, status: :started)
  end

  def end_game
    @game_state.update!(status: :ended)
  end

  private

  def start_first_turn
    @record.current_turn = 1
  end

  def refresh_hand(hand_set)
    @record.hand_1 = hand_set.cards[0].to_s
    @record.hand_2 = hand_set.cards[1].to_s
    @record.hand_3 = hand_set.cards[2].to_s
    @record.hand_4 = hand_set.cards[3].to_s
    @record.hand_5 = hand_set.cards[4].to_s
  end

  def save_current_state
    @record.save!
    @record
  end
end
