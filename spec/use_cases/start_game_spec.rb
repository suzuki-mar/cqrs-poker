# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ゲーム開始' do
  let(:logger) { TestLogger.new }
  let(:command_handler) { UseCaseHelper.build_command_handler(logger) }
  let(:context) { CommandContext.build_for_game_start }

  before do
    GameState.destroy_all
  end

  context '正常系' do
    describe 'ゲームが正しく開始されること' do
      let(:command) { Command.new }

      before do
        command_handler.handle(command, context)
      end

      it 'イベントが正しく発行されること' do
        event = EventStore.last
        expect(event.event_type).to eq('game_started')
        # 必要ならevent.event_dataの内容も検証
      end

      it 'ログが正しく出力されること' do
        expect(logger.messages_for_level(:info)).to include(/イベント受信: ゲーム開始/)
      end

      it 'ゲーム状態が正しく更新されること' do
        game_state = GameState.find_current_session
        aggregate_failures do
          expect(game_state).to be_started
          expect(game_state.hand_set.size).to eq(HandSet::CARDS_IN_HAND)
          expect(game_state.current_turn).to eq(1)
        end
      end

      it '表示用のデータが正しく整形されること' do
        read_model = GameStateReadModel.new
        display_data = read_model.current_state_for_display

        aggregate_failures do
          expect(display_data[:status]).to eq('started')
          expect(display_data[:hand].split(' ').size).to eq(HandSet::CARDS_IN_HAND)
          expect(display_data[:turn]).to eq(1)
        end
      end
    end
  end

  context '異常系' do
    context 'ゲームがすでに開始されている場合' do
      subject { command_handler.handle(Command.new, context) }

      before do
        # 最初のゲーム開始
        command_handler.handle(Command.new, context)
      end

      it 'InvalidCommandEventが発行・保存されること' do
        # 2回目のゲーム開始
        subject
        event_store_holder = EventStoreHolder.new
        last_event = event_store_holder.latest_event
        expect(last_event.event_type).to eq('invalid_command_event')
        expect(last_event.to_event_data[:reason]).to include('ゲームはすでに開始されています')
      end

      it 'GameStartedイベントが2回記録されないこと' do
        expect {
          subject
        }.not_to change { EventStore.where(event_type: 'game_started').count }
      end

      it 'GameStateが変更されないこと' do
        original_game_state = GameState.find_current_session.attributes

        subject rescue nil

        expect(GameState.find_current_session.attributes).to eq(original_game_state)
      end

      it 'warnログが出力されること' do
        subject
        expect(logger.messages_for_level(:warn).last).to match(/不正な選択肢の選択/)
        expect(logger.messages_for_level(:warn).last).to include('ゲームはすでに開始されています')
      end
    end
  end
end
