class Projection
  def handle_event(event)
    player_hand_state = ReadModels::PlayerHandState.new

    if event.is_a?(CommandErrors::InvalidCommand) || event.is_a?(CommandErrors::VersionConflict)
      return player_hand_state
    end

    apply_to_player_hand_state(player_hand_state, event)
    accept_to_trash_state_if_exchanged(event, player_hand_state)
    ReadModels::Histories.add(player_hand_state.hand_set, event.event_id.value) if event.is_a?(GameEndedEvent)

    player_hand_state
  end

  private

  def apply_to_player_hand_state(player_hand_state, event)
    case event
    when GameStartedEvent
      player_hand_state.start_new_game!(event)
    when CardExchangedEvent
      player_hand_state.exchange_card!(event)
    when GameEndedEvent
      player_hand_state.end_game!(event)
    else
      raise ArgumentError, "未対応のイベントです: #{event.class.name}"
    end
  end

  def accept_to_trash_state_if_exchanged(event, player_hand_state)
    return unless event.is_a?(CardExchangedEvent)

    current_turn = player_hand_state.current_turn
    last_event_id = event.event_id.value
    ReadModels::TrashState.load.accept!(event.to_event_data[:discarded_card], current_turn, last_event_id)
  end
end
