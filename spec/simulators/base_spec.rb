require 'rails_helper'

RSpec.describe 'シミュレーターの基本動作' do
  let!(:logger) { TestLogger.new }

  context 'イベント通知なしの場合' do
    let!(:command_bus) { CommandBusAssembler.build(logger: logger) }
    let(:simulator) { Simulator.new }

    before do
      simulator.instance_variable_set(:@command_bus, command_bus)
    end

    it 'ゲーム開始コマンドを実行できること' do
      start_command = Commands::GameStart.new
      result = simulator.run(start_command)

      expect(result.success?).to be true
      expect(result.event).to be_a(GameStartedEvent)
    end
  end

  describe 'イベント通知機能' do
    let(:simulator) { Simulator.new }
    let!(:command_bus) do
      CommandBusAssembler.build(logger: logger, failure_handler: simulator, simulator: simulator)
    end

    before do
      simulator.instance_variable_set(:@command_bus, command_bus)
    end

    it 'コマンド実行成功時にイベント通知を受け取ること' do
      start_command = Commands::GameStart.new
      expect(simulator.event_handled).to be false

      simulator.run(start_command)

      expect(simulator.event_handled).to be true
    end

    it '複数のコマンドを連続して実行し、イベントが記録されること' do
      # 1. ゲーム開始
      start_command = Commands::GameStart.new
      start_result = simulator.run(start_command)
      expect(start_result.success?).to be true
      game_number = start_result.event.game_number

      # 2. カード交換
      query_service = QueryService.new(game_number)
      card_to_discard = query_service.player_hand_set.cards.first
      exchange_command = Commands::ExchangeCard.new(card_to_discard, game_number)
      exchange_result = simulator.run(exchange_command)
      expect(exchange_result.success?).to be true

      # 3. 検証
      expect(simulator.event_handled).to be true
    end

    context 'コマンドが失敗した場合' do
      it 'handle_failureメソッドが呼び出されること' do
        expect(simulator.failure_handled).to be false

        # 明らかに失敗するコマンド（存在しないゲーム）を実行
        command = Commands::EndGame.new(GameNumber.new(99_999))
        result = simulator.run(command)

        # 失敗した結果が返ってくること
        expect(result.failure?).to be true

        # handle_failureが呼び出されたことを検証
        expect(simulator.failure_handled).to be true
      end
    end
  end
end
