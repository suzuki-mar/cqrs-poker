# typed: true

require 'rails_helper'

RSpec.describe ExchangeCardSelector::EvaluationResult do
  describe '#better_than?' do
    context '自分自身がDO_NOT_EXCHANGEの場合' do
      it 'StandardErrorが発生すること' do
        do_not_exchange_result = ExchangeCardSelector::EvaluationResult.build_do_not_exchange
        normal_result = ExchangeCardSelector::EvaluationResult.new(
          ExchangeCardSelector::EvaluationResult::Confidence::MEDIUM,
          []
        )

        expect { do_not_exchange_result.better_than?(normal_result) }.to raise_error(
          StandardError,
          '戦略不適用の結果は他の戦略と比較すべきではありません'
        )
      end
    end

    context '自分自身がALREADY_COMPLETEの場合' do
      it 'StandardErrorが発生すること' do
        perfect_result = ExchangeCardSelector::EvaluationResult.build_no_exchange_needed
        normal_result = ExchangeCardSelector::EvaluationResult.new(
          ExchangeCardSelector::EvaluationResult::Confidence::MEDIUM,
          []
        )

        expect { perfect_result.better_than?(normal_result) }.to raise_error(
          StandardError,
          '完成役の結果は他の戦略と比較すべきではありません'
        )
      end
    end

    context '自分自身がONE_AWAY_GUARANTEEDの場合' do
      it 'StandardErrorが発生すること' do
        guaranteed_result = ExchangeCardSelector::EvaluationResult.new(
          ExchangeCardSelector::EvaluationResult::Confidence::ONE_AWAY_GUARANTEED,
          []
        )
        normal_result = ExchangeCardSelector::EvaluationResult.new(
          ExchangeCardSelector::EvaluationResult::Confidence::MEDIUM,
          []
        )

        expect { guaranteed_result.better_than?(normal_result) }.to raise_error(
          StandardError,
          '保証された結果は他の戦略と比較すべきではありません'
        )
      end
    end

    context 'DO_NOT_EXCHANGEの結果と比較しようとした場合' do
      it 'ArgumentErrorが発生すること' do
        normal_result = ExchangeCardSelector::EvaluationResult.new(
          ExchangeCardSelector::EvaluationResult::Confidence::MEDIUM,
          []
        )
        do_not_exchange_result = ExchangeCardSelector::EvaluationResult.build_do_not_exchange

        expect { normal_result.better_than?(do_not_exchange_result) }.to raise_error(
          ArgumentError,
          '戦略不適用の結果と比較することはできません'
        )
      end
    end

    context 'ALREADY_COMPLETEの結果と比較しようとした場合' do
      it 'ArgumentErrorが発生すること' do
        normal_result = ExchangeCardSelector::EvaluationResult.new(
          ExchangeCardSelector::EvaluationResult::Confidence::MEDIUM,
          []
        )
        perfect_result = ExchangeCardSelector::EvaluationResult.build_no_exchange_needed

        expect { normal_result.better_than?(perfect_result) }.to raise_error(
          ArgumentError,
          '完成役の結果と比較することはできません'
        )
      end
    end

    context 'ONE_AWAY_GUARANTEEDの結果と比較しようとした場合' do
      it 'ArgumentErrorが発生すること' do
        normal_result = ExchangeCardSelector::EvaluationResult.new(
          ExchangeCardSelector::EvaluationResult::Confidence::MEDIUM,
          []
        )
        guaranteed_result = ExchangeCardSelector::EvaluationResult.new(
          ExchangeCardSelector::EvaluationResult::Confidence::ONE_AWAY_GUARANTEED,
          []
        )

        expect { normal_result.better_than?(guaranteed_result) }.to raise_error(
          ArgumentError,
          '保証された結果と比較することはできません'
        )
      end
    end

    context '正常な比較の場合' do
      it 'HIGHがMEDIUMより優れていることを返すこと' do
        high_result = ExchangeCardSelector::EvaluationResult.new(
          ExchangeCardSelector::EvaluationResult::Confidence::HIGH,
          []
        )
        medium_result = ExchangeCardSelector::EvaluationResult.new(
          ExchangeCardSelector::EvaluationResult::Confidence::MEDIUM,
          []
        )

        expect(high_result.better_than?(medium_result)).to be true
      end

      it 'MEDIUMがHIGHより劣っていることを返すこと' do
        medium_result = ExchangeCardSelector::EvaluationResult.new(
          ExchangeCardSelector::EvaluationResult::Confidence::MEDIUM,
          []
        )
        high_result = ExchangeCardSelector::EvaluationResult.new(
          ExchangeCardSelector::EvaluationResult::Confidence::HIGH,
          []
        )

        expect(medium_result.better_than?(high_result)).to be false
      end
    end
  end
end
