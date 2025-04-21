require 'rails_helper'

RSpec.describe BoardAggregate do
  describe '#draw_initial_hand' do
    let(:board) { described_class.new }

    it 'draw_initial_handで5枚配られ、deckのカード枚数も5枚減ること' do
      before_count = board.send(:deck).cards.size
      hand = board.draw_initial_hand
      after_count = board.send(:deck).cards.size

      aggregate_failures do
        expect(hand.cards.size).to eq(5)
        expect(after_count).to eq(before_count - 5)
      end
    end
  end
end
