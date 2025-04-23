class Projection
  def handle_event(event)
    read_model = ReadModels::GameStateReadModel.new

    case event
    when GameStartedEvent
      read_model.start_new_game!(event)
    when CardExchangedEvent
      read_model.exchange_card!(event)
    when InvalidCommandEvent
      return read_model
    else
      raise ArgumentError, "未対応のイベントです: #{event.class.name}"
    end

    read_model
  end
end
