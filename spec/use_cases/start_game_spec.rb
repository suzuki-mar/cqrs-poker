# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ゲーム開始' do
  let(:logger) { TestLogger.new }
  let(:event_publisher) { EventPublisher.new(projection: Projection.new, event_listener: log_event_listener) }
  let(:log_event_listener) { LogEventListener.new(logger) }
  let(:event_bus) { EventBus.new(event_publisher) }
  let(:command_handler) { CommandHandler.new(event_bus) }
  let(:board) { BoardAggregate.new }
  let(:context) { CommandContext.build_for_game_start }

  describe 'ゲーム開始時' do
    before do
      GameState.destroy_all
    end

    context '正常系' do
      describe 'ゲームが正しく開始されること' do
        let(:command) { GameStartCommand.new }

        before do
          command_handler.handle(command, context)
        end

        it 'イベントが正しく発行されること' do
          published_event = event_publisher.published_events.last
          expect(published_event).to be_a(GameStartedEvent)
          expect(published_event.initial_hand.cards.size).to eq(HandSet::CARDS_IN_HAND)
        end

        it 'ログが正しく出力されること' do
          expect(logger.messages_for_level(:info)).to include(/イベント受信: ゲーム開始/)
        end

        it 'ゲーム状態が正しく更新されること' do
          game_state = GameState.last
          aggregate_failures do
            expect(game_state).to be_started
            expect(game_state.hand_cards.size).to eq(HandSet::CARDS_IN_HAND)
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
        before do
          # 最初のゲーム開始
          command_handler.handle(GameStartCommand.new, context)
        end

        it 'InvalidCommandエラーが発生すること' do
          # 2回目のゲーム開始
          expect {
            command_handler.handle(GameStartCommand.new, context)
          }.to raise_error(InvalidCommand, "ゲームはすでに開始されています")
        end

        it 'GameStartedイベントが2回記録されないこと' do
          expect {
            command_handler.handle(GameStartCommand.new, context) rescue nil
          }.not_to change(EventStore, :count)
        end

        it 'GameStateが変更されないこと' do
          original_game_state = GameState.last.attributes

          command_handler.handle(GameStartCommand.new, context) rescue nil

          expect(GameState.last.attributes).to eq(original_game_state)
        end
      end
    end
  end
end
