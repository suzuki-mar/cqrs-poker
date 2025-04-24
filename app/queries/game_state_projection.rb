class GameStateProjection
  def handle_event(event)
    case event
    when GameStartedEvent
      handle_game_started(event)
    end
  end

  private

  def handle_game_started(event)
    game_state = GameState.new(
      status: :started,
      current_turn: 1,
      current_rank: event.to_event_data[:evaluate]
    )
    game_state.assign_hand_number_from_set(event.to_event_data[:initial_hand])
    game_state.save!
  end
end
