class Projection
  def handle_event(event)
    read_model = PlayerHandStateReadModel.new

    return read_model if event.is_a?(InvalidCommandEvent) || event.is_a?(VersionConflictEvent)

    apply_to_read_model(read_model, event)

    read_model
  end

  private

  def apply_to_read_model(read_model, event)
    case event
    when GameStartedEvent
      read_model.start_new_game!(event)
    when CardExchangedEvent
      read_model.exchange_card!(event)
    when GameEndedEvent
      read_model.end_game!(event)
    else
      raise ArgumentError, "未対応のイベントです: #{event.class.name}"
    end
  end
end
