require 'rails_helper'

RSpec.describe ReadModels::PlayerHandStateReadModel do
  describe '#current_state_for_display' do
    it 'returns formatted display data' do
      player_hand_state = create(:player_hand_state, status: :started)
      read_model = described_class.new

      display_data = read_model.current_state_for_display

      expect(display_data[:status]).to eq('started')
      expect(display_data[:hand]).to eq(player_hand_state.hand_set.join(' '))
      expect(display_data[:current_rank]).to eq(ReadModels::HandSet::Rank::HIGH_CARD)
      expect(display_data[:rank_name]).to eq('ハイカード')
      expect(display_data[:turn]).to eq(1)
    end
  end
end
