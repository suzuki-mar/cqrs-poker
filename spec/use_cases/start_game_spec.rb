# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ゲーム開始' do
  let!(:logger) { TestLogger.new }
  let!(:command_bus) do
    failure_handler = DummyFailureHandler.new
    CommandBusAssembler.build(
      logger: logger,
      failure_handler: failure_handler
    )
  end

  context '正常系' do
    describe 'ゲームが正しく開始されること' do
      let!(:command) { Commands::GameStart.new }

      subject { command_bus.execute(Commands::GameStart.new) }

      it 'イベントが正しく発行されること' do
        subject

        event_store_holder = Aggregates::Store.new
        event = event_store_holder.latest_event
        expect(event.event_type).to eq(GameStartedEvent.event_type)
      end

      it 'ログが正しく出力されること' do
        subject

        expect(logger.messages_for_level(:info)).to include(/イベント受信: ゲーム開始/)
      end

      it 'ゲーム状態が正しく更新されること' do
        subject

        display_data = QueryService.last_game_player_hand_summary

        expect(display_data[:status]).to eq('started')
        expect(display_data[:hand_set].size).to eq(GameRule::MAX_HAND_SIZE)
      end

      it '表示用のデータが正しく整形されること' do
        subject

        display_data = QueryService.last_game_player_hand_summary

        expect(display_data[:status]).to eq('started')
        expect(display_data[:hand_set].size).to eq(GameRule::MAX_HAND_SIZE)
      end

      it 'バージョン履歴を作成していること' do
        subject

        query_service = QueryService.build_last_game_query_service
        version_info = query_service.all_projection_versions

        latest_event = Aggregates::Store.new.latest_event
        version_ids = version_info.map(&:last_event_id)

        expect(version_ids).to all(eq(latest_event.event_id))
        expect(version_ids.size).to eq(query_service.all_projection_versions.size)
      end

      it '捨て札が用意されていること' do
        subject

        query_service = QueryService.build_last_game_query_service
        trash_state = query_service.trash_state

        expect(trash_state.exists?).to be_truthy
        expect(trash_state.empty?).to be_truthy
      end

      it 'ゲーム終了記録が作成されていないこと' do
        subject
        query_service = QueryService.build_last_game_query_service
        expect(query_service.ended_game_recorded?).to be false
      end
    end

    context 'ゲームがすでに開始されている場合' do
      it '新しいゲームを開始できること' do
        command_bus.execute(Commands::GameStart.new)
        command_bus.execute(Commands::GameStart.new)

        expect(QueryService.number_of_games).to eq(2)
      end
    end
  end
end
