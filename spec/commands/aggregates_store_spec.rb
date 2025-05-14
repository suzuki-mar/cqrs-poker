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

  describe 'version管理' do
    let(:aggregate_store) { described_class.new }

    it 'versionが1から始まり、連番で保存されること' do
      event1 = GameStartedEvent.new(CustomFaker.high_card_hand)
      event2 = CardExchangedEvent.new(HandSet::Card.new('♠A'), HandSet::Card.new('♣2'))
      aggregate_store.append_event(event1, GameNumber.new(1))
      aggregate_store.append_event(event2, GameNumber.new(1))
      versions = Event.order(:version).pluck(:version)
      expect(versions).to eq([1, 2])
    end

    it 'version競合時はCommandErrors::VersionConflictを返すこと' do
      event1 = GameStartedEvent.new(CustomFaker.high_card_hand)
      aggregate_store.append_event(event1, GameNumber.new(1))
      # 同じバージョンで再度append
      result = aggregate_store.append_event(event1, GameNumber.new(1))
      expect(result.error).to be_a(CommandErrors::VersionConflict)
      expect(result.error.expected_version).to be >= 1
      expect(result.error.actual_version).to be >= 0
    end

    it '並行保存時のversion競合（簡易シミュレーション）' do
      aggregate_store = Aggregates::Store.new
      event1 = GameStartedEvent.new(CustomFaker.high_card_hand)
      aggregate_store.append_event(event1, GameNumber.new(1))
      # v2を2回同時に保存しようとする
      result = aggregate_store.append_event(event1, GameNumber.new(1))
      expect(result.error).to be_a(CommandErrors::VersionConflict)
      expect(result.error).to be_a(CommandErrors::VersionConflict)
    end

    # スナップショット整合性テストは、スナップショット機能実装後に追加
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
