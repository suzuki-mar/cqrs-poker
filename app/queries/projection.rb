class Projection
  def handle_event(event)
    player_hand_state = ReadModels::PlayerHandState.new

    if event.is_a?(CommandErrors::InvalidCommand) || event.is_a?(CommandErrors::VersionConflict)
      return player_hand_state
    end

    apply_to_player_hand_state(player_hand_state, event)

    ReadModels::Histories.add(player_hand_state.hand_set) if event.is_a?(SuccessEvents::GameEnded)

    player_hand_state
  end

  private

  def apply_to_player_hand_state(player_hand_state, event)
    case event
    when SuccessEvents::GameStarted
      player_hand_state.start_new_game!(event)
    when SuccessEvents::CardExchanged
      player_hand_state.exchange_card!(event)
    when SuccessEvents::GameEnded
      player_hand_state.end_game!(event)
    else
      raise ArgumentError, "未対応のイベントです: #{event.class.name}"
    end
  end
end
