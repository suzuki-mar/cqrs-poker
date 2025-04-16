class Projection
  def receive(event)
    case event
    when GameStartedEvent
      handle_game_started(event)
    else
      raise ArgumentError, "未対応のイベントです: #{event.class.name}"
    end
  end

  private

  def handle_game_started(event)
    read_model = GameStateReadModel.new
    read_model.update_for_game_started(event)
  end
end
