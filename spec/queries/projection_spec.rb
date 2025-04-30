require 'rails_helper'

RSpec.describe Projection do
  describe '#handle_event' do
    context 'GameStartedEventを受け取った場合' do
      let(:compare_card) { HandSet::Card.new('♠7') }
      let(:initial_hand) do
        HandSet.build([compare_card] + [HandSet::Card.new('♥A'), HandSet::Card.new('♦2'), HandSet::Card.new('♣3'),
                                        HandSet::Card.new('♠4')])
      end
      let(:event) { SuccessEvents::GameStarted.new(initial_hand) }
      let(:projection) { described_class.new }

      it 'ゲーム状態を開始状態に更新すること' do
        read_model = projection.handle_event(event)
        state = read_model.current_state_for_display

        aggregate_failures do
          expect(state[:status]).to eq('started')
          expect(state[:current_rank]).to eq(initial_hand.evaluate.to_s)
          expect(state[:turn]).to eq(1)
          expect(state[:hand]).to include(compare_card.to_s)
        end
      end
    end
  end
end
