# typed: true

require 'rails_helper'
require_relative 'shareds'

RSpec.describe ExchangeCardSelector::CompleteHandStrategy do
  let!(:trash_state) { create(:trash_state) }

  describe '#execute' do
    context '完成役の場合' do
      context 'ストレート（5-9）の場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♥5', '♦6', '♣7', '♠8', '♥9']) }

        include_examples '完成役として交換しないこと'
      end

      context 'フラッシュ（♠）の場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♠A', '♠K', '♠Q', '♠J', '♠9']) }

        include_examples '完成役として交換しないこと'
      end

      context 'ストレートフラッシュ（♥5-9）の場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♥5', '♥6', '♥7', '♥8', '♥9']) }

        include_examples '完成役として交換しないこと'
      end

      context 'ロイヤルフラッシュ（♠）の場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♠A', '♠K', '♠Q', '♠J', '♠10']) }

        include_examples '完成役として交換しないこと'
      end
    end

    context 'あと1枚で完成する場合' do
      context 'ストレートドロー（4枚連続）の場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♥5', '♦6', '♣7', '♠8', '♥K']) }

        it 'HIGH信頼度で1枚交換すること' do
          expect(subject.exchange_cards.map(&:number)).to eq(['K'])
          expect(subject.confidence).to eq(ExchangeCardSelector::EvaluationResult::Confidence::HIGH)
        end
      end

      context 'フラッシュドロー（同じスーツ4枚）の場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♠A', '♠K', '♠Q', '♠J', '♥3']) }

        it 'HIGH信頼度で1枚交換すること' do
          expect(subject.exchange_cards.map(&:number)).to eq(['3'])
          expect(subject.confidence).to eq(ExchangeCardSelector::EvaluationResult::Confidence::HIGH)
        end
      end
    end

    context 'あと2枚で完成する場合' do
      context 'ストレートドロー（3枚連続）の場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♥5', '♦6', '♣7', '♠K', '♥A']) }

        it 'MEDIUM信頼度で2枚交換すること' do
          expect(subject.exchange_cards.map(&:number).sort).to eq(%w[A K])
          expect(subject.confidence).to eq(ExchangeCardSelector::EvaluationResult::Confidence::MEDIUM)
        end
      end

      context 'フラッシュドロー（同じスーツ3枚）の場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♠A', '♠K', '♠Q', '♥3', '♦7']) }

        it 'MEDIUM信頼度で2枚交換すること' do
          expect(subject.exchange_cards.map(&:number).sort).to eq(%w[3 7])
          expect(subject.confidence).to eq(ExchangeCardSelector::EvaluationResult::Confidence::MEDIUM)
        end
      end
    end

    context 'あと3枚で完成する場合' do
      context 'ペアがない場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♥5', '♦6', '♣K', '♠A', '♥3']) }

        it 'LOW信頼度で3枚交換すること' do
          expect(subject.exchange_cards.map(&:number).sort).to eq(%w[3 A K])
          expect(subject.confidence).to eq(ExchangeCardSelector::EvaluationResult::Confidence::LOW)
        end
      end

      context 'ペアがある場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♥5', '♦6', '♣K', '♠K', '♥3']) }

        include_examples '戦略不適用を返すこと'
      end
    end

    context 'フラッシュとストレートの両方の可能性がある場合' do
      subject { described_class.new(hand_set, trash_state).execute }
      let(:hand_set) { SimulatorTestHelper.build_hand(['♠A', '♠K', '♠Q', '♥J', '♦9']) }

      it 'より高い信頼度の戦略を選択すること' do
        expect(subject.exchange_cards.map(&:number)).to eq(['9'])
        expect(subject.confidence).to eq(ExchangeCardSelector::EvaluationResult::Confidence::HIGH)
      end
    end

    context 'ストレート・フラッシュに向かない場合' do
      context 'ワンペアの場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♦K', '♣9', '♠7', '♥3']) }

        include_examples '戦略不適用を返すこと'
      end

      context 'ツーペアの場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♦K', '♣9', '♠9', '♥3']) }

        include_examples '戦略不適用を返すこと'
      end

      context 'スリーカードの場合' do
        subject { described_class.new(hand_set, trash_state).execute }
        let(:hand_set) { SimulatorTestHelper.build_hand(['♥K', '♦K', '♣K', '♠9', '♥3']) }

        include_examples '戦略不適用を返すこと'
      end
    end
  end
end
