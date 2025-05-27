# frozen_string_literal: true

require 'rails_helper'
require 'support/use_case_shared'

RSpec.describe 'ゲーム終了ユースケース' do
  let(:logger) { TestLogger.new }
  let!(:command_bus) { UseCaseHelper.build_command_bus(logger) }

  context '正常系' do
    before do
      # まずゲームを開始しておく
      command_bus.execute(Commands::GameStart.new)
    end

    subject do
      game_number = QueryService.latest_game_number
      command_bus.execute(Commands::EndGame.new(game_number))
    end

    it 'GameEndedEventがEventStoreに記録されること' do
      game_number = QueryService.latest_game_number
      command_bus.execute(Commands::EndGame.new(game_number))
      event = Aggregates::Store.new.latest_event
      expect(event.event_type).to eq(GameEndedEvent.event_type)
    end

    it 'ログにゲーム終了が記録されること' do
      game_number = QueryService.latest_game_number
      command_bus.execute(Commands::EndGame.new(game_number))
      expect(logger.messages_for_level(:info)).to include(/イベント受信: ゲーム終了/)
    end

    it 'PlayerHandStateの状態が終了済みになること' do
      game_number = QueryService.latest_game_number
      command_bus.execute(Commands::EndGame.new(game_number))

      query_service = QueryService.new(game_number)
      player_hand_summary = query_service.player_hand_summary

      expect(player_hand_summary[:status]).to eq('ended')
    end

    it 'Historyクラスが生成され、最終手札とcurrentRankを保持していること' do
      command_bus.execute(Commands::GameStart.new)
      game_number_for_end = QueryService.latest_game_number
      command_bus.execute(Commands::EndGame.new(game_number_for_end))
      query_service = QueryService.new(game_number_for_end)
      expect(query_service.ended_game_recorded?).to be true
      summary = query_service.player_hand_summary

      expect(summary[:hand_set]).not_to be_nil
      expect(summary[:rank]).not_to be_nil
    end

    # 捨て札のバージョンはアップデートをしないのでこれは実行しない
    # it_behaves_like 'version history update examples' # from support/use_case_shared

    describe 'ゲーム終了の捨て札管理' do
      let(:game_number) { QueryService.latest_game_number }

      it 'バージョン履歴で捨て札のバージョンだけは上がっていないこと' do
        query_service = QueryService.new(game_number)
        all_versions_before = query_service.all_projection_versions
        trash_before = all_versions_before.find { |vi| vi.projection_name == 'trash' }

        command_bus.execute(Commands::EndGame.new(game_number))

        all_versions_after = query_service.all_projection_versions
        trash_after = all_versions_after.find { |vi| vi.projection_name == 'trash' }

        expect(trash_after.last_event_id).to eq(trash_before.last_event_id)
      end
    end
  end

  context '異常系' do
    context 'ゲームが開始されていない状態で終了しようとする' do
      subject do
        game_number = GameNumber.new(CustomFaker.game_number)
        command_bus.execute(Commands::EndGame.new(game_number))
      end

      it_behaves_like 'return command error use_case', :game_not_found
    end

    context '複数のゲームが存在する場合' do
      subject do
        command_bus.execute(Commands::GameStart.new)
        first_game_number = QueryService.latest_game_number

        non_existent_game_number = GameNumber.new(first_game_number.value + 1)
        command_bus.execute(Commands::EndGame.new(non_existent_game_number))
      end

      it_behaves_like 'return command error use_case', :game_not_found
    end

    context 'ゲームが終了している状態でゲームを終了する' do
      subject do
        command_bus.execute(Commands::GameStart.new)
        game_number = QueryService.latest_game_number

        command_bus.execute(Commands::EndGame.new(game_number))
        command_bus.execute(Commands::EndGame.new(game_number))
      end

      it_behaves_like 'return command error use_case', :game_already_ended
    end
  end
end
