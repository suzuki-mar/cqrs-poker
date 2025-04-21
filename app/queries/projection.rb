class Projection
  def receive(event)
    read_model = GameStateReadModel.new

    case event
    when GameStartedEvent
      read_model.update_for_game_started(event)
    else
      raise ArgumentError, "未対応のイベントです: #{event.class.name}"
    end

    read_model
  end
end
