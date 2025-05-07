require 'rails_helper'

RSpec.describe Aggregates::Store do
  describe '#append' do
    let(:initial_hand) { Faker.high_card_hand }
    let(:event) { GameStartedEvent.new(initial_hand) }
    let(:aggregate_store) { Aggregates::Store.new }

    it '受け取ったイベントを保存できること' do
      expect do
        result = aggregate_store.append_event(event)
        expect(result.event).to be_a(GameStartedEvent)
      end.to change(Event, :count).by(1)

      saved_event = Event.last
      expect(saved_event.event_type).to eq(GameStartedEvent.event_type)
      expect(saved_event.event_data).to eq(event.to_serialized_hash.to_json)
    end

    it '予期しない例外はそのままraiseされること' do
      aggregate_store = Aggregates::Store.new
      event = GameStartedEvent.new(Faker.high_card_hand)
      allow(Event).to receive(:create!).and_raise(StandardError, 'DB接続断')
      expect do
        aggregate_store.append_event(event)
      end.to raise_error(StandardError, 'DB接続断')
    end
  end

  describe 'version管理' do
    let(:aggregate_store) { Aggregates::Store.new }

    it 'versionが1から始まり、連番で保存されること' do
      aggregate_store = Aggregates::Store.new
      event1 = GameStartedEvent.new(Faker.high_card_hand)
      event2 = CardExchangedEvent.new(HandSet::Card.new('♠A'), HandSet::Card.new('♣2'))
      aggregate_store.append_event(event1)
      aggregate_store.append_event(event2)
      versions = Event.order(:version).pluck(:version)
      expect(versions).to eq([1, 2])
    end

    it 'version重複時はFailureで返ること' do
      aggregate_store = Aggregates::Store.new
      event1 = GameStartedEvent.new(Faker.high_card_hand)
      aggregate_store.append_event(event1)
      # 同じバージョンで再度append
      result = aggregate_store.append_event(event1)
      expect(result.error).to be_a(CommandErrors::VersionConflict)
      expect(result.error.expected_version).to be >= 1
      expect(result.error.actual_version).to be >= 0
    end

    it '並行保存時のversion競合（簡易シミュレーション）' do
      aggregate_store = Aggregates::Store.new
      event1 = GameStartedEvent.new(Faker.high_card_hand)
      aggregate_store.append_event(event1)
      # v2を2回同時に保存しようとする
      result = aggregate_store.append_event(event1)
      expect(result.error).to be_a(CommandErrors::VersionConflict)
      expect(result.error).to be_a(CommandErrors::VersionConflict)
    end

    # スナップショット整合性テストは、スナップショット機能実装後に追加
  end
end
