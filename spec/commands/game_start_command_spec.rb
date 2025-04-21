require 'rails_helper'

RSpec.describe GameStartCommand do
  let(:board) { BoardAggregate.new }
  let(:hand) { board.draw_initial_hand }

  describe '#execute' do
    it '初期手札（HandSet）が返ること' do
      result = described_class.new.execute(board)
      expect(result).to be_a(HandSet)
      expect(result.cards.size).to eq(5)
    end
  end
end
