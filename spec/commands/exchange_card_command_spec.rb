require 'rails_helper'

RSpec.describe ExchangeCardCommand do
  let(:game_state) { create(:game_state, :started) }
  let(:board) { BoardAggregate.new }
  let(:discarded_card) { board.draw_card }

  xdescribe '#execute' do
    context 'カード交換が可能な状態の場合' do
      it 'カードが正しく交換されること' do
        command = described_class.new
        expect { command.execute(board, discarded_card) }.to change {
          game_state.reload.current_hand_set
        }
      end
    end

    context 'ゲームが開始されていない場合' do
      before { game_state.destroy }

      it 'エラーが発生すること' do
        command = described_class.new
        expect { command.execute(board, discarded_card) }.to raise_error(
          InvalidCommand, 'ゲームが開始されていません'
        )
      end
    end
  end
end
