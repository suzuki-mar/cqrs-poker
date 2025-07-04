# typed: true

require 'rails_helper'
require_relative 'shareds'

RSpec.describe ExchangeCardSelector::FullHouseStrategy do
  let!(:trash_state) { create(:trash_state) }

  describe '#execute' do
    context 'ワンペアの場合' do
      subject { described_class.new(hand_set, trash_state).execute }
      let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♦K', '♣9', '♠7', '♥3']) }

      include_examples '指定されたカードを交換すること', %w[3 7 9], ExchangeCardSelector::EvaluationResult::Confidence::LOW
    end

    context 'ツーペアの場合' do
      subject { described_class.new(hand_set, trash_state).execute }
      let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♦K', '♣9', '♠9', '♥3']) }

      include_examples '指定されたカードを交換すること', %w[3], ExchangeCardSelector::EvaluationResult::Confidence::HIGH
    end

    context 'スリーカードの場合' do
      subject { described_class.new(hand_set, trash_state).execute }
      let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♦K', '♣K', '♠9', '♥3']) }

      include_examples '指定されたカードを交換すること', %w[3 9], ExchangeCardSelector::EvaluationResult::Confidence::MEDIUM
    end

    context 'ハイカードの場合' do
      subject { described_class.new(hand_set, trash_state).execute }
      let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♦J', '♣9', '♠7', '♥3']) }

      include_examples '戦略不適用を返すこと'
    end
  end
end
