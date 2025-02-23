require 'rails_helper'
require 'rake'

RSpec.describe 'game:start task' do
  before(:all) do  
    Rails.application.load_tasks
  end

  # 標準出力は実装の詳細なので、このテストでは実行の確認のみを行う
  it 'StartGameUseCaseを実行すること' do
    allow(StartGameUseCase).to receive(:new).and_return(spy('StartGameUseCase'))
    Rake::Task['game:start'].execute
    expect(StartGameUseCase).to have_received(:new)
  end
end 