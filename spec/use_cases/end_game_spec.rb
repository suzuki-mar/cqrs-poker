# frozen_string_literal: true

require 'rails_helper'
require 'support/use_case_shared'

RSpec.describe 'ゲーム終了ユースケース' do
  let(:logger) { TestLogger.new }
  let!(:command_bus) { UseCaseHelper.build_command_bus(logger) }
  let(:read_model) { ReadModels::PlayerHandState.new }
  let(:main_command_context) do
    Aggregates::Store.new.latest_event.game_number
  end

  context '正常系' do
    before do
      # まずゲームを開始しておく
      command_bus.execute(Command.new, CommandContext.build_for_game_start)
    end

    subject do
      game_number = Aggregates::Store.new.latest_event.game_number
      command_bus.execute(Command.new, CommandContext.build_for_end_game(game_number: game_number))
    end

    it 'GameEndedEventがEventStoreに記録されること' do
      game_number = Aggregates::Store.new.latest_event.game_number
      command_bus.execute(Command.new, CommandContext.build_for_end_game(game_number: game_number))
      event = Event.last
      expect(event.event_type).to eq(GameEndedEvent.event_type)
    end

    it 'ログにゲーム終了が記録されること' do
      game_number = Aggregates::Store.new.latest_event.game_number
      command_bus.execute(Command.new, CommandContext.build_for_end_game(game_number: game_number))
      expect(logger.messages_for_level(:info)).to include(/イベント受信: ゲーム終了/)
    end

    it 'PlayerHandStateの状態が終了済みになること' do
      game_number = Aggregates::Store.new.latest_event.game_number
      command_bus.execute(Command.new, CommandContext.build_for_end_game(game_number: game_number))
      player_game_state = Query::PlayerHandState.find_current_session
      expect(player_game_state.status).to eq('ended')
    end

    it 'Historyクラスが生成され、最終手札とcurrentRankを保持していること' do
      game_number = Aggregates::Store.new.latest_event.game_number
      command_bus.execute(Command.new, CommandContext.build_for_end_game(game_number: game_number))
      histories = ReadModels::Histories.load(limit: 1)
      history = histories.first
      read_model = ReadModels::PlayerHandState.new

      expect(history).not_to be_nil
      expect(history.hand_set).to eq(read_model.hand_set.cards.map(&:to_s))
      expect(history.rank).to eq(HandSet::Rank::ALL.index(read_model.hand_set.evaluate))
    end

    # 捨て札のバージョンはアップデートをしないのでこれは実行しない
    # it_behaves_like 'version history update examples' # from support/use_case_shared

    describe 'ゲーム終了の捨て札管理' do
      let(:game_number) { Aggregates::Store.new.latest_event.game_number }
      let(:player_hand_state) { ReadModels::PlayerHandState.new }
      let(:original_hand) { player_hand_state.hand_set }
      let(:discarded_card) { original_hand.cards.first }

      before do
        exchange_context = CommandContext.build_for_exchange(discarded_card: discarded_card, game_number: game_number)
        command_bus.execute(Command.new, exchange_context)
      end

      it 'バージョン履歴で捨て札のバージョンだけは上がっていないこと' do
        version_info_before = ReadModels::ProjectionVersions.load
        all_versions_before = version_info_before.fetch_all_versions
        trash_before = all_versions_before.find { |vi| vi.projection_name == 'trash' }

        command_bus.execute(Command.new, CommandContext.build_for_end_game(game_number: game_number))

        version_info_after = ReadModels::ProjectionVersions.load
        all_versions_after = version_info_after.fetch_all_versions
        trash_after = all_versions_after.find { |vi| vi.projection_name == 'trash' }

        expect(trash_after.last_event_id).to eq(trash_before.last_event_id)
      end
    end
  end
  context '異常系' do
    it 'ゲームが開始されていない状態で終了しようとするとInvalidCommandEventが発行されること' do
      game_number = 1 # 適当な値、またはテスト用にセットアップ
      result = command_bus.execute(Command.new, CommandContext.build_for_end_game(game_number: game_number))
      expect(result.error).to be_a(CommandErrors::InvalidCommand)
      expect(result.error.reason).to eq('ゲームが進行中ではありません')
    end
  end
end
