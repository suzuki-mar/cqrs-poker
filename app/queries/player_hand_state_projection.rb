class PlayerHandStateProjection
  def handle_event(event)
    case event
    when GameStartedEvent
      handle_game_started(event)
    end
  end

  def handle_game_started(event)
    player_game_state = PlayerHandState.new(
      status: :started,
      current_turn: 1,
      current_rank: event.to_event_data[:evaluate]
    )
    player_game_state.assign_hand_number_from_set(event.to_event_data[:initial_hand])
    player_game_state.save!
  end
end
