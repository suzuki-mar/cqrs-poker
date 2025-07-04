# typed: true

require 'rails_helper'
require_relative 'shareds'

RSpec.describe ExchangeCardSelector::HighCardStrategy do
  let!(:trash_state) { create(:trash_state) }

  describe '#execute' do
    context 'ハイカードの場合' do
      subject { described_class.new(hand_set, trash_state).execute }
      let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♦J', '♣9', '♠7', '♥3']) }

      include_examples '指定されたカードを交換すること', %w[3 7 9 J], ExchangeCardSelector::EvaluationResult::Confidence::LOW
    end

    context 'すでに役が完成している場合' do
      context 'ワンペアの場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♦K', '♣9', '♠7', '♥3']) }

        include_examples '戦略不適用を返すこと'
      end

      context 'フラッシュの場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♥J', '♥9', '♥7', '♥3']) }

        include_examples '戦略不適用を返すこと'
      end

      context 'ストレートの場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♦Q', '♣J', '♠10', '♥9']) }

        include_examples '戦略不適用を返すこと'
      end

      context 'フルハウスの場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♦K', '♣K', '♠7', '♥7']) }

        include_examples '戦略不適用を返すこと'
      end
    end
  end
end
