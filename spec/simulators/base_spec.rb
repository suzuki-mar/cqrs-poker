require 'rails_helper'

RSpec.describe 'シミュレーターの基本動作' do
  let!(:logger) { TestLogger.new }
  let!(:command_bus) { UseCaseHelper.build_command_bus(logger) }

  it 'ゲームを開始できること' do
    # Simulatorでゲーム開始
    simulator = Simulator.new(command_bus)
    result = simulator.start

    # CommandResultが成功していることを確認
    expect(result.success?).to be true
    expect(result.event).to be_a(GameStartedEvent)

    # QueryServiceで状態を確認
    display_data = QueryService.last_game_player_hand_summary
    expect(display_data[:status]).to eq('started')
  end
end
