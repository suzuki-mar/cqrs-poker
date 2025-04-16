require 'rails_helper'

RSpec.describe EventStoreHolder do
  describe '#append' do
    let(:initial_hand) { Faker.high_card_hand }
    let(:event) { GameStartedEvent.new(initial_hand) }
    let(:event_store_holder) { EventStoreHolder.new }

    it '受け取ったイベントを保存できること' do
      expect {
        event_store_holder.append(event)
      }.to change(EventStore, :count).by(1)

      saved_event = EventStore.last
      expect(saved_event.event_type).to eq(GameStartedEvent::EVENT_TYPE)
      expect(saved_event.event_data).to eq(event.to_event_data.to_json)
    end
  end
end
