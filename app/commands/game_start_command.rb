class GameStartCommand
  def initialize(event_store_domain)
    @event_store_domain = event_store_domain
  end

  def execute
    # 初期手札を生成
    initial_hand = Deck.instance.generate_hand

    # イベントを生成
    event = GameStartedEvent.new(initial_hand)

    # イベントをイベントストアに追加
    @event_store_domain.append(event)

    event
  end
end
