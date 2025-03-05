require 'rails_helper'

RSpec.describe GameStateDomain do
  describe '#start_game' do
    let(:initial_hand) { Faker.high_card_hand }

    it 'ゲームの状態が開始されていること' do
      domain = described_class.new
      domain.start_game(initial_hand)

      game_state = GameState.first

      expect(game_state.current_turn).to eq(1)
      expect(game_state.current_rank).to eq(initial_hand.evaluate)
      expect(game_state.hand_cards).to eq(initial_hand.cards.map(&:to_s))
    end
  end
end
