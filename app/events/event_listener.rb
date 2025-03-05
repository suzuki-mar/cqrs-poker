class EventListener
  def initialize(game_state_domain)
    @game_state_domain = game_state_domain
  end

  def handle_event(event)
    case event.event_type
    when Events::Type::GAME_STARTED
      handle_game_started(event)
    # 将来的に他のイベントタイプを追加
    # when Events::Type::CARDS_EXCHANGED
    #   handle_cards_exchanged(event)
    else
      Rails.logger.warn "未対応のイベントタイプです: #{event.event_type}"
    end
  end

  private

  def handle_game_started(event)
    # GameStateDomainを使用してゲーム状態を更新
    @game_state_domain.start_game(event.initial_hand)

    Rails.logger.info "ゲーム開始イベントを処理しました: #{event.to_event_data}"
  end

  # 将来的に他のイベントハンドラを追加
  # def handle_cards_exchanged(event)
  #   # カード交換イベントの処理
  # end
end
