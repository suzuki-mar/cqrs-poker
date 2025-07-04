# typed: true

require 'rails_helper'
require_relative 'shareds'

RSpec.describe ExchangeCardSelector::FourOfAKindStrategy do
  describe '#execute' do
    context 'スリーカードでフォーカード可能な場合' do
      context '捨て札に同じ数字があるとき' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♦K', '♣K', '♠9', '♥3']) }
        let(:trash_state) { create(:trash_state, discarded_cards: ['♠K', '♦2']) }

        include_examples '指定されたカードを交換すること', %w[3 9], ExchangeCardSelector::EvaluationResult::Confidence::MEDIUM
      end

      context '捨て札に同じ数字がないとき' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♦K', '♣K', '♠9', '♥3']) }
        let(:trash_state) { create(:trash_state, discarded_cards: ['♠A', '♦2']) }

        include_examples '指定されたカードを交換すること', %w[3 9], ExchangeCardSelector::EvaluationResult::Confidence::MEDIUM
      end
    end

    context 'スリーカードでない場合' do
      subject { described_class.new(hand_set, trash_state).execute }
      let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♦K', '♣9', '♠7', '♥3']) }
      let(:trash_state) { create(:trash_state) }

      include_examples '戦略不適用を返すこと'
    end

    context 'すでにフォーカードの場合' do
      subject { described_class.new(hand_set, trash_state).execute }
      let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♦K', '♣K', '♠K', '♥3']) }
      let(:trash_state) { create(:trash_state) }

      include_examples '戦略不適用を返すこと'
    end
  end
end
