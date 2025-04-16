require 'rails_helper'

RSpec.describe Projection do
  describe '#receive' do
    context 'GameStartedEventを受け取った場合' do
      let(:initial_hand) { HandSet.generate_initial }
      let(:event) { GameStartedEvent.new(initial_hand) }

      it 'ReadModelを通じてゲーム状態を更新すること' do
        projection = described_class.new
        projection.receive(event)

        read_model = GameStateReadModel.new
        state = read_model.current_state_for_display

        aggregate_failures do
          expect(state[:status]).to eq('started')
          expect(state[:current_rank]).to eq(initial_hand.evaluate.to_s)
          expect(state[:turn]).to eq(1)
          expect(state[:hand]).to eq(initial_hand.cards.map(&:to_s).join(" "))
        end
      end
    end
  end
end
