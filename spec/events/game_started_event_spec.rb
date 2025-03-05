require 'rails_helper'

RSpec.describe GameStartedEvent do
  let(:hand) { HandSet.generate_initial }
  let(:event) { described_class.new(hand) }

  describe '#event_type' do
    it "'game_started'を返すこと" do
      expect(event.event_type).to eq('game_started')
    end
  end

  describe '#to_event_data' do
    it '初期手札のデータを含むハッシュを返すこと' do
      event_data = event.to_event_data
      expect(event_data).to be_a(Hash)
      expect(event_data[:initial_hand]).to eq(hand.cards.map(&:to_s))
    end
  end
end
