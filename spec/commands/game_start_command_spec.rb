require 'rails_helper'

RSpec.describe GameStartCommand do
  describe '#execute' do
    let(:event_store_domain) { EventStoreDomain.new }
    let(:command) { GameStartCommand.new(event_store_domain) }

    it 'ゲーム開始イベントを作成して返すこと' do
      fixed_hand = Faker.high_card_hand
      allow(Deck.instance).to receive(:generate_hand).and_return(fixed_hand)

      result = command.execute

      expect(result).to be_a(GameStartedEvent)
      expect(result.initial_hand).to eq(fixed_hand)
    end

    it 'イベントストアにイベントを保存すること' do
      expect {
        command.execute
      }.to change(EventStore, :count).by(1)
    end
  end
end
