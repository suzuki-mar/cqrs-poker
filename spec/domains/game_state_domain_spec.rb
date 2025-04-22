require 'rails_helper'

RSpec.describe GameStateDomain do
  describe '#start_game' do
    let(:game_state) { GameState.new }
    let(:domain) { described_class.new(game_state) }

    it 'ゲームの状態が開始されていること' do
      initial_hand = Faker.high_card_hand
      domain.start_game(initial_hand)

      expect(game_state.hand_set).to eq(initial_hand.cards.map(&:to_s))
      expect(game_state.current_rank).to eq(initial_hand.evaluate)
      expect(game_state.current_turn).to eq(1)
    end
  end
end
