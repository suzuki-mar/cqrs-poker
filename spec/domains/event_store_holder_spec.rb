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

  describe '#current_hand_set' do
    let(:event_store_holder) { EventStoreHolder.new }

    it '複数回のカード交換をリプレイして最新の手札を正しく再現できること' do
      # ゲーム開始
      initial_hand = [ Card.new('♠A'), Card.new('♥2'), Card.new('♦3'), Card.new('♣4'), Card.new('♠5') ]
      event_store_holder.append(GameStartedEvent.new(HandSet.build(initial_hand)))

      # 1回目の交換
      discarded = initial_hand[0]
      new_card = Card.new('♣6')
      event_store_holder.append(CardExchangedEvent.new(discarded, new_card))

      # 最新の手札を取得
      latest_hand_set = event_store_holder.current_hand_set
      expect(latest_hand_set).to be_a(HandSet)
      expect(latest_hand_set.cards).to include(new_card1, new_card2, new_card3)
      expect(latest_hand_set.cards.size).to eq(5)
      # 交換していないカードも含まれていること
      expect(latest_hand_set.cards).to include(initial_hand[3], initial_hand[4])
    end
  end
end
