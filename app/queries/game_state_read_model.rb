class GameStateReadModel
  def initialize
    @game_state = GameState.last || GameState.new
  end

  def start_new_game!(event)
    @game_state = GameState.new
    @game_state.status = :started
    @game_state.current_rank = event.evaluate
    @game_state.current_turn = 1
    @game_state.assign_hand_number_from_set(event.initial_hand)
    @game_state.save!
  end

  def exchange_card!(event)
    # 現在の手札をHandSetとして再構築
    hand_set = HandSet.build(@game_state.hand_cards.map { |str| Card.new(str) })
    # 手札を交換
    new_hand_set = hand_set.rebuild_after_exchange(event.discarded_card, event.new_card)
    # GameStateを更新
    @game_state.assign_hand_number_from_set(new_hand_set)
    @game_state.current_rank = new_hand_set.evaluate
    @game_state.current_turn += 1
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
