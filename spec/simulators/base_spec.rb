require 'rails_helper'

RSpec.describe 'シミュレーターの基本動作' do
  let!(:logger) { TestLogger.new }
  let!(:simulator) { Simulator.new(logger) }
  let!(:command_bus) do
    CommandBusAssembler.build(failure_handler: simulator, simulator: simulator)
  end

  describe 'シミュレーターの連続実行' do
    it 'ゲーム開始から終了までの一連の流れを自動で実行できること' do
      # シミュレーションを開始
      simulator.run(command_bus)

      # 最終的にゲーム終了イベントがログに出力されていることを確認
      log_output = logger.full_log
      expect(log_output).to include('Simulator: イベント[GameStartedEvent]を処理しました。')
      expect(log_output).to include('Simulator: イベント[CardExchangedEvent]を処理しました。')
      expect(log_output).to include('Simulator: イベント[GameEndedEvent]を処理しました。')
    end
  end
end
