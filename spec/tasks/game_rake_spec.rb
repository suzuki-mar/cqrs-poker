require 'rails_helper'
require 'rake'

RSpec.describe 'game:start task' do
  before(:all) do
    # Rakeタスクをロード
    Rails.application.load_tasks
  end

  it 'StartGameUseCaseが実行されること' do
    use_case = instance_double(StartGameUseCase)
    expect(StartGameUseCase).to receive(:new).and_return(use_case)
    expect(use_case).to receive(:execute)

    # タスクを実行
    Rake::Task['start'].execute
  end
end 