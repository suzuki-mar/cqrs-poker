require 'rails_helper'

RSpec.describe ReadModels::PlayerHandState do
  describe 'rank_groups' do
    let(:game_number) { GameNumber.new(1) }
    let(:player_hand_state_record) do
      Query::PlayerHandState.new(
        game_number: game_number.value,
        hand_set: hand_cards,
        current_rank: 'HIGH_CARD',
        current_turn: 1,
        status: 'started',
        last_event_id: 1
      )
    end
    let(:player_hand_state) { described_class.send(:new, player_hand_state_record) }

    context '2種類以上のペアがある場合' do
      let(:hand_cards) { %w[♥A ♠A ♦10 ♣10 ♥K] }

      it 'ペアの塊が2配列返ること' do
        result = player_hand_state.rank_groups

        aggregate_failures do
          expect(result.size).to eq(2)
          expect(result[0].size).to eq(2)
          expect(result[1].size).to eq(2)
          expect(result[0].all? { |card| card.number == 'A' }).to be true
          expect(result[1].all? { |card| card.number == '10' }).to be true
        end
      end
    end

    context '1種類だけのペアがある場合' do
      let(:hand_cards) { %w[♥A ♠A ♦10 ♣J ♥K] }

      it 'ペアの塊が1配列返ること' do
        result = player_hand_state.rank_groups

        aggregate_failures do
          expect(result.size).to eq(1)
          expect(result[0].size).to eq(2)
          expect(result[0].all? { |card| card.number == 'A' }).to be true
        end
      end
    end

    context 'ペアが全くない場合' do
      let(:hand_cards) { %w[♥A ♠2 ♦10 ♣J ♥K] }

      it '空配列が返ること' do
        result = player_hand_state.rank_groups
        expect(result).to eq([])
      end
    end
  end
end
