class GameStateReadModel
  def initialize
    @game_state = GameState.last || GameState.new
  end

  def update_for_game_started(event)
    @game_state.status = :started
    @game_state.current_rank = event.evaluate
    @game_state.current_turn = 1
    @game_state.assign_hand_number_from_set(event.initial_hand)
    @game_state.save!
  end

  def current_state_for_display
    {
      status: game_state.status,
      hand: format_hand,
      current_rank: game_state.current_rank,
      rank_name: HandSet::Rank.japanese_name(game_state.current_rank),
      turn: game_state.current_turn
    }
  end

  private

  attr_reader :game_state

  def format_hand
    game_state.hand_cards.join(" ")
  end
end
