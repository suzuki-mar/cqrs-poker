# frozen_string_literal: true

module EventListener
  class Projection
    def handle_event(event)
      player_hand_state = build_player_hand_state(event)

      update_projection_versions(event)
      apply_to_player_hand_state(player_hand_state, event)

      ReadModels::Histories.add(player_hand_state.hand_set, event) if event.is_a?(GameEndedEvent)
      update_trash_state(event, player_hand_state)
      player_hand_state
    end

    private

    def build_player_hand_state(event)
      if event.is_a?(GameStartedEvent)
        ReadModels::PlayerHandState.build_from_event(event)
      else
        ReadModels::PlayerHandState.load_by_game_number(event.game_number)
      end
    end

    def apply_to_player_hand_state(player_hand_state, event)
      case event
      when GameStartedEvent
        player_hand_state.start_new_game!(event)
      when CardExchangedEvent
        player_hand_state.exchange_card!(event)
      when GameEndedEvent
        # @type var event: GameEndedEvent
        player_hand_state.end_game!(event)
      else
        raise ArgumentError, "未対応のイベントです: #{event.class.name}"
      end
    end

    def update_projection_versions(event)
      return if event.is_a?(GameEndedEvent)

      # GameEndedEvent以外では全バージョンを更新
      ReadModels::ProjectionVersions.update_all_versions(event)
    end

    def update_trash_state(event, player_hand_state)
      if event.is_a?(GameStartedEvent)
        game_number = event.game_number
        first_event_id = event.event_id
        ReadModels::TrashState.prepare!(game_number, first_event_id)

      elsif event.is_a?(CardExchangedEvent)
        current_turn = player_hand_state.current_turn
        last_event_id = event.event_id.value
        game_number = event.game_number
        ReadModels::TrashState.load(game_number).accept!(
          event.to_event_data[:discarded_card],
          current_turn,
          last_event_id
        )

      end
    end
  end
end
