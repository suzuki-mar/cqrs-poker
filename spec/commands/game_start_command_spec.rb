require 'rails_helper'

RSpec.describe GameStartCommand do
  let(:deck) { Deck.instance }

  describe '.execute' do
    subject { described_class.execute(deck) }

    it 'ゲーム開始イベントが正しく生成されること' do
      event = subject

      aggregate_failures do
        expect(event.event_type).to eq GameStartedEvent::EVENT_TYPE
        expect(event.initial_hand.cards.size).to eq HandSet::CARDS_IN_HAND
        expect(event.to_event_data).to include(
          initial_hand: be_an(Array)
        )
      end
    end
  end
end
