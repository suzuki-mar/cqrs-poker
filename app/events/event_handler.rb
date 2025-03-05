class EventHandler
  def initialize(repository, event_publisher)
    @repository = repository
    @event_publisher = event_publisher
  end

  def handle(event)
    case event.type
    when :game_start
      handle_game_start(event)
    when :cards_exchanged
      handle_cards_exchanged(event)
    else
      raise "Unsupported event type: #{event.type}"
    end
  end

  private

  def handle_game_start(event)
    game = @repository.find_or_create_game
    game.start
    @repository.save(game)
    @event_publisher.publish("game_started")
  end

  def handle_cards_exchanged(event)
    # カード交換のロジック
    # ここに具体的な処理を記述
  end
end 