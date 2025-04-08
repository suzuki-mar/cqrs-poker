require 'rails_helper'

RSpec.describe Projection do
  let(:game_state_domain) { instance_double(GameStateDomain) }
  let(:projection) { described_class.new(game_state_domain) }

  describe '#receive' do
    context 'GameStartedEventを受け取った場合' do
      let(:initial_hand) { Faker.high_card_hand }
      let(:event) { GameStartedEvent.new(initial_hand) }

      it 'ゲーム状態を開始状態に更新すること' do
        expect(game_state_domain).to receive(:start_game).with(initial_hand)
        projection.receive(event)
      end
    end
  end
end
