require 'rails_helper'

RSpec.describe EventStoreDomain do
  describe '#append' do
    let(:initial_hand) { Deck.instance.generate_hand_set }
    let(:event) { GameStartedEvent.new(initial_hand) }
    let(:event_store_domain) { EventStoreDomain.new }

    it '受け取ったイベントを保存できること' do
      expect {
        event_store_domain.append(event)
      }.to change(EventStore, :count).by(1)

      saved_event = EventStore.last
      expect(saved_event.event_type).to eq(EventType::GAME_STARTED)
      expect(saved_event.event_data).to eq(event.to_event_data.to_json)
    end
  end
end
