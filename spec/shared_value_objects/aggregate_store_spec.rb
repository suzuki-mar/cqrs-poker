require 'rails_helper'

RSpec.describe Aggregates::Store do
  describe '#append' do
    let(:initial_hand) { Faker.high_card_hand }
    let(:event) { SuccessEvents::GameStarted.new(initial_hand) }
    let(:aggregate_store) { Aggregates::Store.new }

    it '受け取ったイベントを保存できること' do
      current_version = aggregate_store.current_version
      expect do
        result = aggregate_store.append(event, current_version)
        expect(result).to be_a(SuccessEvents::GameStarted)
      end.to change(Event, :count).by(1)

      saved_event = Event.last
      expect(saved_event.event_type).to eq(SuccessEvents::GameStarted.event_type)
      expect(saved_event.event_data).to eq(event.to_serialized_hash.to_json)
    end

    it '予期しない例外はそのままraiseされること' do
      aggregate_store = Aggregates::Store.new
      event = SuccessEvents::GameStarted.new(Faker.high_card_hand)
      v = aggregate_store.current_version
      allow(Event).to receive(:create!).and_raise(StandardError, 'DB接続断')
      expect do
        aggregate_store.append(event, v)
      end.to raise_error(StandardError, 'DB接続断')
    end
  end

  describe 'version管理' do
    let(:aggregate_store) { Aggregates::Store.new }

    it 'versionが1から始まり、連番で保存されること' do
      aggregate_store = Aggregates::Store.new
      event1 = SuccessEvents::GameStarted.new(Faker.high_card_hand)
      event2 = SuccessEvents::CardExchanged.new(HandSet::Card.new('♠A'), HandSet::Card.new('♣2'))
      v1 = aggregate_store.current_version
      aggregate_store.append(event1, v1)
      v2 = aggregate_store.current_version
      aggregate_store.append(event2, v2)
      versions = Event.order(:version).pluck(:version)
      expect(versions).to eq([1, 2])
    end

    it 'version重複時はFailureで返ること' do
      aggregate_store = Aggregates::Store.new
      event1 = SuccessEvents::GameStarted.new(Faker.high_card_hand)
      v1 = aggregate_store.current_version
      aggregate_store.append(event1, v1)
      # 同じバージョンで再度append
      result = aggregate_store.append(event1, v1)
      expect(result).to be_a(FailureEvents::VersionConflict)
      expect(result.event_type).to eq(FailureEvents::VersionConflict.event_type)
      expect(result).to be_a(FailureEvents::VersionConflict)
      expect(result.to_event_data[:expected_version]).to be >= 1
      expect(result.to_event_data[:actual_version]).to be >= 0
    end

    it '並行保存時のversion競合（簡易シミュレーション）' do
      aggregate_store = Aggregates::Store.new
      event1 = SuccessEvents::GameStarted.new(Faker.high_card_hand)
      v1 = aggregate_store.current_version
      aggregate_store.append(event1, v1)
      # v2を2回同時に保存しようとする
      v2 = aggregate_store.current_version
      result = aggregate_store.append(event1, v2)
      expect(result).to be_a(FailureEvents::VersionConflict)
      expect(result.event_type).to eq(FailureEvents::VersionConflict.event_type)
    end

    # スナップショット整合性テストは、スナップショット機能実装後に追加
  end
end
