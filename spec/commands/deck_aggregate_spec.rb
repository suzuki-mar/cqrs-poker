require 'rails_helper'

RSpec.describe DeckAggregate do
  describe '#draw_initial_hand' do
    let(:deck) { described_class.build }

    it '5枚のカードが引かれ、デッキから除外されること' do
      initial_deck_size = deck.size
      drawn_hand = deck.draw_initial_hand

      aggregate_failures do
        expect(drawn_hand.cards.size).to eq(5)
        expect(deck.size).to eq(initial_deck_size - 5)

        drawn_hand.cards.each do |card|
          expect(deck.cards).not_to include(card)
        end
      end
    end
  end
end
