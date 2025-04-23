require 'rails_helper'

RSpec.describe AggregateStore do
  describe '#append' do
    let(:initial_hand) { Faker.high_card_hand }
    let(:event) { GameStartedEvent.new(initial_hand) }
    let(:aggregate_store) { AggregateStore.new }

    it '受け取ったイベントを保存できること' do
      expect {
        aggregate_store.append(event)
      }.to change(EventStore, :count).by(1)

      saved_event = EventStore.last
      expect(saved_event.event_type).to eq(GameStartedEvent::EVENT_TYPE)
      expect(saved_event.event_data).to eq(event.to_event_data.to_json)
    end
  end

  describe '#current_hand_set' do
    let(:aggregate_store) { AggregateStore.new }

    it '複数回のカード交換をリプレイして最新の手札を正しく再現できること' do
      # ゲーム開始
      initial_hand = [ Card.new('♠A'), Card.new('♥2'), Card.new('♦3'), Card.new('♣4'), Card.new('♠5') ]
      aggregate_store.append(GameStartedEvent.new(ReadModels::HandSet.build(initial_hand)))

      # 1回目の交換
      discarded1 = initial_hand[0]
      new_card1 = Card.new('♣6')
      aggregate_store.append(CardExchangedEvent.new(discarded1, new_card1))

      # 2回目の交換
      latest_hand_set = aggregate_store.current_hand_set
      discarded2 = latest_hand_set.cards.find { |c| c != new_card1 && !initial_hand.include?(c) } || initial_hand[1]
      new_card2 = Card.new('♦7')
      aggregate_store.append(CardExchangedEvent.new(discarded2, new_card2))

      # 3回目の交換
      latest_hand_set = aggregate_store.current_hand_set
      discarded3 = latest_hand_set.cards.find { |c| c != new_card1 && c != new_card2 && !initial_hand.include?(c) } || initial_hand[2]
      new_card3 = Card.new('♥8')
      aggregate_store.append(CardExchangedEvent.new(discarded3, new_card3))

      # 最新の手札を取得
      latest_hand_set = aggregate_store.current_hand_set
      expect(latest_hand_set).to be_a(ReadModels::HandSet)
      expect(latest_hand_set.cards).to include(new_card1, new_card2, new_card3)
      expect(latest_hand_set.cards.size).to eq(5)
      # 交換していないカードも含まれていること
      expect(latest_hand_set.cards).to include(initial_hand[3], initial_hand[4])
    end
  end
end
