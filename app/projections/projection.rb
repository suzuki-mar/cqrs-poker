class Projection
  def initialize(game_state_domain)
    @game_state_domain = game_state_domain
  end

  def receive(event)
    case event.event_type
    when EventType::GAME_STARTED
      @game_state_domain.start_game(event.initial_hand)
      Rails.logger.info "ゲーム開始イベントを処理しました: #{event.to_event_data}"
    else
      Rails.logger.warn "未対応のイベントタイプです: #{event.event_type}"
    end
  end
end
