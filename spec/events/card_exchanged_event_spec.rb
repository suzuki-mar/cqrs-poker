require 'rails_helper'

RSpec.describe CardExchangedEvent do
  let(:discarded_card) { Card.new("H1") }  # ハートのエース
  let(:new_card) { Card.new("S2") }        # スペードの2
  let(:event) { described_class.new(discarded_card: discarded_card, new_card: new_card) }

  describe '#event_type' do
    it "'card_exchanged'を返すこと" do
      expect(event.event_type).to eq('card_exchanged')
    end
  end

  describe '#to_event_data' do
    it '交換されたカードの情報を含むハッシュを返すこと' do
      event_data = event.to_event_data
      expect(event_data).to be_a(Hash)
      expect(event_data[:discarded_card]).to eq("H1")
      expect(event_data[:new_card]).to eq("S2")
    end
  end
end
