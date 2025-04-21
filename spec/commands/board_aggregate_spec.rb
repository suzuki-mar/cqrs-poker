require 'rails_helper'

RSpec.describe BoardAggregate do
  describe '#draw_initial_hand' do
    let(:board) { described_class.new }

    it '5枚のカードが引かれ、山札から除外されること' do
      initial_deck_count = board.remaining_deck_count
      drawn_hand = board.draw_initial_hand

      aggregate_failures do
        expect(drawn_hand.cards.size).to eq(5)
        expect(board.remaining_deck_count).to eq(initial_deck_count - 5)

        drawn_hand.cards.each do |card|
          expect(board.deck_cards).not_to include(card)
        end
      end
    end
  end
end
