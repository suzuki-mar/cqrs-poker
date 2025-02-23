require 'rails_helper'
require 'rake'

RSpec.describe 'game:start task' do
  before(:all) do  
    Rails.application.load_tasks
  end

  it 'ゲームを開始できること' do
    expect {
      Rake::Task['game:start'].execute
    }.not_to raise_error
  end
end 