module ReadModels
  class PlayerHandState
    def initialize
      @player_hand_state = Query::PlayerHandState.find_current_session || Query::PlayerHandState.new
    end

    def start_new_game!(event)
      @player_hand_state = Query::PlayerHandState.new(
        status: 'started',
        current_rank: event.to_event_data[:evaluate],
        current_turn: 1,
        hand_set: event.to_event_data[:initial_hand].map(&:to_s),
        last_event_id: event.event_id.value,
        game_number: event.game_number.value
      )

      player_hand_state.save!
    end

    def exchange_card!(event)
      new_hand_set = build_exchanged_hand_set(
        event.to_event_data[:discarded_card],
        event.to_event_data[:new_card]
      )

      # カードが存在しない場合は処理をスキップ
      return if new_hand_set.nil?

      @player_hand_state.hand_set = new_hand_set.cards.map(&:to_s)
      player_hand_state.current_rank = new_hand_set.evaluate
      player_hand_state.current_turn += 1
      player_hand_state.save!
    end

    def current_state_for_display
      {
        status: player_hand_state.status,
        hand: format_hand,
        current_rank: player_hand_state.current_rank,
        rank_name: HandSet.rank_japanese_name(player_hand_state.current_rank),
        turn: player_hand_state.current_turn
      }
    end

    def hand_set
      HandSet.build(player_hand_state.hand_set.map { |c| HandSet.build_card_for_query(c) })
    end

    def refreshed_hand_set
      @player_hand_state = Query::PlayerHandState.find_current_session
      hand_set
    end

    def end_game!(_event)
      player_hand_state.status = 'ended'
      player_hand_state.save!
    end

    delegate :current_turn, to: :player_hand_state

    delegate :last_event_id, to: :player_hand_state

    private

    attr_reader :player_hand_state

    def format_hand
      player_hand_state.hand_set.join(' ')
    end

    def build_exchanged_hand_set(discarded_card, new_card)
      hand_set = HandSet.build(player_hand_state.hand_set.map { |c| HandSet.build_card_for_query(c) })
      hand_set.rebuild_after_exchange(discarded_card, new_card)
    end
  end
end
