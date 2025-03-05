class GameStartCommand
  def initialize(event_store_domain)
    @event_store_domain = event_store_domain
  end

  def execute
    # 初期手札を生成
    initial_hand_set = Deck.instance.generate_hand_set

    # イベントを生成
    event = GameStartedEvent.new(initial_hand_set)

    # イベントをイベントストアに追加
    @event_store_domain.append(event)

    # アクション完了通知
    EventBus.instance.notify_when_action_completed("game_started")

    event
  end
end
