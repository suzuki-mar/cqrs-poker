require 'rails_helper'

describe Aggregates::Store do
  describe '#append_event' do
    let(:initial_hand) { CustomFaker.high_card_hand }
    let(:event) { GameStartedEvent.new(initial_hand) }
    let(:aggregate_store) { described_class.new }

    it 'イベントを保存できること' do
      expect do
        result = aggregate_store.append_event(event, GameNumber.new(1))
        expect(result.event).to be_a(GameStartedEvent)
      end.to change(Event, :count).by(1)

      saved_event = Event.last
      expect(saved_event.event_type).to eq(GameStartedEvent.event_type)
      expect(saved_event.event_data).to eq(event.to_serialized_hash.to_json)
    end

    it 'ActiveRecord::RecordInvalid以外の例外はそのままraiseされること' do
      allow(Event).to receive(:create!).and_raise(StandardError, 'DB接続断')
      expect do
        aggregate_store.append_event(event, GameNumber.new(1))
      end.to raise_error(StandardError, 'DB接続断')
    end
  end

  describe '#append_initial_event' do
    let(:initial_hand) { CustomFaker.high_card_hand }
    let(:event) { GameStartedEvent.new(initial_hand) }
    let(:aggregate_store) { described_class.new }

    it '初期イベントを保存できること' do
      expect do
        result = aggregate_store.append_initial_event(event, GameNumber.new(1))
        expect(result.event).to be_a(GameStartedEvent)
      end.to change(Event, :count).by(1)

      saved_event = Event.last
      expect(saved_event.event_type).to eq(GameStartedEvent.event_type)
      expect(saved_event.event_data).to eq(event.to_serialized_hash.to_json)
      expect(saved_event.game_number).to eq(1)
    end
  end
end
