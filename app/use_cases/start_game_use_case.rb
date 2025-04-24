class StartGameUseCase
  def execute
    command = Commands::StartGameCommand.new
    event = Events::GameStartedEvent.new

    command.execute
    event.apply
  end
end
