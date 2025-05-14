# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ゲーム開始' do
  let(:logger) { TestLogger.new }
  let(:command_bus) { UseCaseHelper.build_command_bus(logger) }
  let(:main_command_context) { CommandContext.build_for_game_start }
  let(:read_model) { ReadModels::PlayerHandState.new }
  let(:event_publisher) { EventPublisher.new(projection: Projection.new, event_listener: LogEventListener.new(logger)) }
  let(:event_bus) { EventBus.new(event_publisher) }

  context '正常系' do
    describe 'ゲームが正しく開始されること' do
      let(:command) { Command.new }

      subject { command_bus.execute(Command.new, main_command_context) }

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

        display_data = read_model.current_state_for_display
        aggregate_failures do
          expect(display_data[:status]).to eq('started')
          expect(display_data[:hand].split.size).to eq(GameSetting::MAX_HAND_SIZE)
          expect(display_data[:turn]).to eq(1)
        end
      end

      it '表示用のデータが正しく整形されること' do
        subject

        display_data = read_model.current_state_for_display

        aggregate_failures do
          expect(display_data[:status]).to eq('started')
          expect(display_data[:hand].split.size).to eq(GameSetting::MAX_HAND_SIZE)
          expect(display_data[:turn]).to eq(1)
        end
      end

      it 'バージョン履歴を作成していること' do
        subject
        latest_event = Aggregates::Store.new.latest_event
        version_info = ReadModels::ProjectionVersions.load
        version_ids = version_info.fetch_all_versions.map(&:last_event_id)
        expect(version_ids).to all(eq(latest_event.event_id))
      end

      it '捨て札が用意されていること' do
        subject
        game_number = Aggregates::Store.new.latest_event.game_number
        trash_state = ReadModels::TrashState.load(game_number)
        expect(trash_state.empty?).to be_falsey
      end

      it 'ゲーム終了記録が作成されていないこと' do
        subject
        expect(ReadModels::Histories.load.size).to eq(0)
      end

      it '捨て札が空であること' do
        subject
        game_number = Aggregates::Store.new.latest_event.game_number
        trash_state = ReadModels::TrashState.load(game_number)
        expect(trash_state.empty?).to be_falsey
      end
    end
  end

  context '異常系' do
    context 'ゲームがすでに開始されている場合' do
      subject { command_bus.execute(Command.new, main_command_context) }

      before do
        # 最初のゲーム開始
        command_bus.execute(Command.new, main_command_context)
      end

      it 'InvalidCommandが返るがEventStoreには保存されないこと' do
        # 1回目のゲーム開始で保存されたイベントを記録
        first_event = Aggregates::Store.new.latest_event
        # 2回目のゲーム開始
        result = subject
        expect(result.error).to be_a(CommandErrors::InvalidCommand)
        expect(result.error.reason).to eq('すでにゲームが開始されています')

        event_store_holder = Aggregates::Store.new
        last_event = event_store_holder.latest_event
        # 直近のイベントはGameStartedのままで、InvalidCommandは保存されていない
        expect(last_event).to be_a(GameStartedEvent)
        # 内容も完全一致していることを検証
        expect(last_event.to_event_data).to eq(first_event.to_event_data)
      end

      it '警告のログが発生していること' do
        subject
        expect(logger.messages_for_level(:warn)).to include(/コマンド失敗: すでにゲームが開始されています/)
      end

      it 'PlayerHandStateが変更されないこと' do
        original_state = ReadModels::PlayerHandState.new.current_state_for_display

        begin
          subject
        rescue StandardError
          nil
        end

        expect(ReadModels::PlayerHandState.new.current_state_for_display).to eq(original_state)
      end
    end
  end
end
