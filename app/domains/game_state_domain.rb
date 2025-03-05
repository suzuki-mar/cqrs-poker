class GameStateDomain
  def initialize
    @record = GameState.first_or_initialize
  end

  def start_game(initial_hand_set)
    @record.assign_hand_number_from_set(initial_hand_set)
    @record.current_rank = initial_hand_set.evaluate
    start_first_turn

    save_current_state
  end

  private

  def start_first_turn
    @record.current_turn = 1
  end

  def save_current_state
    @record.save!
    @record
  end
end
