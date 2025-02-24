require 'rails_helper'

RSpec.describe StartGameUseCase do
  describe '#execute' do
    it 'コマンドとイベントを順番に実行すること' do
      use_case = StartGameUseCase.new
      
      command = instance_double(Commands::StartGameCommand)
      event = instance_double(Events::GameStartedEvent)

      allow(Commands::StartGameCommand).to receive(:new).and_return(command)
      allow(Events::GameStartedEvent).to receive(:new).and_return(event)

      expect(command).to receive(:execute).ordered
      expect(event).to receive(:apply).ordered

      use_case.execute
    end
  end
end 