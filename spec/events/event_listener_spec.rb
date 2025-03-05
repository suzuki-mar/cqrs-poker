require 'rails_helper'

RSpec.describe EventListener do
  describe '#handle_event' do
    let(:game_state_repository) { instance_double(GameStateRepository) }
    let(:event_listener) { EventListener.new(game_state_repository) }

    context 'ゲーム開始イベントの場合' do
      let(:hand) { Faker.high_card_hand }
      let(:event) { GameStartedEvent.new(hand) }
      let(:game_state) { instance_double(GameState, 'initial_hand=' => nil, 'status=' => nil) }

      before do
        allow(game_state_repository).to receive(:find_or_create).and_return(game_state)
        allow(game_state_repository).to receive(:save).and_return(game_state)
      end

      it 'GameStateを更新すること' do
        expect(game_state).to receive(:initial_hand=).with(hand)
        expect(game_state).to receive(:status=).with('started')
        expect(game_state_repository).to receive(:save).with(game_state)

        event_listener.handle_event(event)
      end
    end

    context '未対応のイベントタイプの場合' do
      let(:unknown_event) { double('UnknownEvent', event_type: 'unknown_event') }

      it 'ログに警告を出力すること' do
        expect(Rails.logger).to receive(:warn).with(/未対応のイベントタイプです/)

        event_listener.handle_event(unknown_event)
      end
    end
  end
end
