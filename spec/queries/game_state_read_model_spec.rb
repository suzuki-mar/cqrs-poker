require 'rails_helper'

RSpec.describe GameStateReadModel do
  describe '#current_state_for_display' do
    it 'returns formatted display data' do
      game_state = create(:game_state, status: :started)
      read_model = described_class.new

      display_data = read_model.current_state_for_display

      expect(display_data[:status]).to eq('started')
      expect(display_data[:hand]).to eq(game_state.hand_cards.join(" "))
      expect(display_data[:current_rank]).to eq(HandSet::Rank::HIGH_CARD)
      expect(display_data[:rank_name]).to eq('ハイカード')
      expect(display_data[:turn]).to eq(1)
    end
  end
end
