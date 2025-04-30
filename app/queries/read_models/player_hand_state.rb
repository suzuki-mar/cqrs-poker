module ReadModels
  class PlayerHandState
    def initialize
      @player_hand_state = Query::PlayerHandState.find_current_session || Query::PlayerHandState.new
    end

    def start_new_game!(event)
      @player_hand_state = Query::PlayerHandState.new
      @player_hand_state.status = 'started'
      @player_hand_state.current_rank = event.to_event_data[:evaluate]
      @player_hand_state.current_turn = 1
      @player_hand_state.hand_set = event.to_event_data[:initial_hand].map(&:to_s)
      @player_hand_state.save!
    end

    def exchange_card!(event)
      # 現在の手札をHandSetとして再構築
      hand_set = HandSet.build(@player_hand_state.hand_set.map { |c| HandSet.build_card_for_query(c) })
      # 手札を交換
      new_hand_set = hand_set.rebuild_after_exchange(event.discarded_card, event.new_card)
      # PlayerHandStateを更新
      @player_hand_state.hand_set = new_hand_set.cards.map(&:to_s)
      @player_hand_state.current_rank = new_hand_set.evaluate
      @player_hand_state.current_turn += 1
      @player_hand_state.save!
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
      HandSet.build(@player_hand_state.hand_set.map { |c| HandSet.build_card_for_query(c) })
    end

    def refreshed_hand_set
      @player_hand_state = Query::PlayerHandState.find_current_session
      hand_set
    end

    def end_game!(_event)
      @player_hand_state.status = 'ended'
      @player_hand_state.save!
    end

    private

    attr_reader :player_hand_state

    def format_hand
      player_hand_state.hand_set.join(' ')
    end
  end
end
