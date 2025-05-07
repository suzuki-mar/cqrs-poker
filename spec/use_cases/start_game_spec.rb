# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ゲーム開始' do
  let(:logger) { TestLogger.new }
  let(:command_bus) { UseCaseHelper.build_command_bus(logger) }
  let(:context) { CommandContext.build_for_game_start }
  let(:read_model) { ReadModels::PlayerHandState.new }
  let(:event_publisher) { EventPublisher.new(projection: Projection.new, event_listener: LogEventListener.new(logger)) }
  let(:event_bus) { EventBus.new(event_publisher) }

  context '正常系' do
    describe 'ゲームが正しく開始されること' do
      let(:command) { Command.new }

      before do
        command_bus.execute(command, context)
      end

      it 'イベントが正しく発行されること' do
        event_store_holder = Aggregates::Store.new
        event = event_store_holder.latest_event
        expect(event.event_type).to eq(GameStartedEvent.event_type)
      end

      it 'ログが正しく出力されること' do
        expect(logger.messages_for_level(:info)).to include(/イベント受信: ゲーム開始/)
      end

      it 'ゲーム状態が正しく更新されること' do
        display_data = read_model.current_state_for_display
        aggregate_failures do
          expect(display_data[:status]).to eq('started')
          expect(display_data[:hand].split.size).to eq(GameSetting::MAX_HAND_SIZE)
          expect(display_data[:turn]).to eq(1)
        end
      end

      it '表示用のデータが正しく整形されること' do
        display_data = read_model.current_state_for_display

        aggregate_failures do
          expect(display_data[:status]).to eq('started')
          expect(display_data[:hand].split.size).to eq(GameSetting::MAX_HAND_SIZE)
          expect(display_data[:turn]).to eq(1)
        end
      end

      it 'ゲーム開始直後はHistoryが作成されていないこと' do
        command_bus.execute(Command.new, context)
        expect(Query::History.count).to eq(0)
      end
    end
  end

  context '異常系' do
    context 'ゲームがすでに開始されている場合' do
      subject { command_bus.execute(Command.new, context) }

      before do
        # 最初のゲーム開始
        command_bus.execute(Command.new, context)
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
        # TODO: ARのクラスを使用しないようにする
        original_player_game_state = Query::PlayerHandState.find_current_session.attributes

        begin
          subject
        rescue StandardError
          nil
        end

        expect(Query::PlayerHandState.find_current_session.attributes).to eq(original_player_game_state)
      end
    end

    context 'バージョン競合が発生した場合' do
      it '並行実行でバージョン競合が発生し、警告ログが出力されること' do
        command_bus.instance_variable_set(:@game_start_handler,
                                          SlowCommandHandler.new(CommandHandlers::GameStart.new(event_bus), delay: 0.5))
        command = Command.new
        context = CommandContext.build_for_game_start
        results = []
        threads = Array.new(2) do
          Thread.new do
            results << command_bus.execute(command, context)
          end
        end
        threads.each(&:join)
        expect(results.filter_map { |r| r.event.class if r.success? }).to include(GameStartedEvent)
        expect(results.filter_map do |r|
          r.error.class unless r.success?
        end).to include(CommandErrors::VersionConflict)
        expect(logger.messages_for_level(:warn).last).to match(/コマンド失敗: バージョン競合/)
      end
    end
  end
end
