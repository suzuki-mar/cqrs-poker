require 'rails_helper'

RSpec.describe 'シミュレーターの基本動作' do
  let!(:logger) { TestLogger.new }
  let!(:command_bus) { UseCaseHelper.build_command_bus(logger) }
  let(:simulator) { Simulator.new(command_bus) }

  it 'ゲームを開始できること' do
    # Simulatorでゲーム開始
    result = simulator.start

    # CommandResultが成功していることを確認
    expect(result.success?).to be true
    expect(result.event).to be_a(GameStartedEvent)

    # QueryServiceで状態を確認
    display_data = QueryService.last_game_player_hand_summary
    expect(display_data[:status]).to eq('started')
  end

  describe 'イベント通知機能' do
    let!(:event_listener) { EventListener::Log.new(logger) }
    let!(:projection) { EventListener::Projection.new }
    let!(:event_publisher) { EventPublisher.new(projection: projection, event_listener: event_listener) }
    let!(:event_bus) { EventBus.new(event_publisher) }
    let!(:command_bus_with_publisher) { CommandBus.new(event_bus, logger) }
    let(:simulator) { Simulator.new(command_bus_with_publisher) }

    before do
      event_publisher.subscribe(simulator)
    end

    it 'コマンド実行成功時にイベント通知を受け取ること' do
      # 初期状態では完了イベントは空
      expect(simulator.completed_events).to be_empty

      # ゲーム開始コマンドを実行
      result = simulator.start

      # コマンドが成功していることを確認
      expect(result.success?).to be true
      expect(result.event).to be_a(GameStartedEvent)

      # イベント通知が届いていることを確認
      expect(simulator.completed_events).not_to be_empty
      expect(simulator.completed_events.size).to eq(1)
      expect(simulator.completed_events.first).to be_a(GameStartedEvent)
      expect(simulator.completed_events.first.game_number).to eq(result.event.game_number)
    end

    it '複数のイベントが発生した場合に全て記録されること' do
      # ゲーム開始
      start_result = simulator.start
      expect(start_result.success?).to be true

      # 初回のイベントが記録されていることを確認
      expect(simulator.completed_events.size).to eq(1)
      expect(simulator.completed_events.first).to be_a(GameStartedEvent)

      # カード交換コマンドを実行（追加のイベントをテスト）
      game_number = start_result.event.game_number
      query_service = QueryService.new(game_number)
      current_hand = query_service.player_hand_set

      exchange_command = Commands::ExchangeCard.new(
        current_hand.cards.first,
        game_number
      )

      exchange_result = command_bus_with_publisher.execute(exchange_command)
      expect(exchange_result.success?).to be true

      # 2つのイベントが記録されていることを確認
      expect(simulator.completed_events.size).to eq(2)
      expect(simulator.completed_events.first).to be_a(GameStartedEvent)
      expect(simulator.completed_events.second).to be_a(CardExchangedEvent)
    end
  end
end
