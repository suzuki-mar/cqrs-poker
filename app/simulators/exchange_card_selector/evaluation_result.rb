# typed: true

class ExchangeCardSelector
  class EvaluationResult
    module Confidence
      ALREADY_COMPLETE = 5
      ONE_AWAY_GUARANTEED = 4
      HIGH = 3
      MEDIUM = 2
      LOW = 1
      DO_NOT_EXCHANGE = 0
    end

    attr_reader :confidence, :exchange_cards

    def initialize(confidence, exchange_cards)
      @confidence = confidence
      @exchange_cards = exchange_cards
    end

    def self.build_do_not_exchange
      new(Confidence::DO_NOT_EXCHANGE, [])
    end

    def self.build_no_exchange_needed
      new(Confidence::ALREADY_COMPLETE, [])
    end

    def better_than?(other_result)
      raise_if_invalid_comparison(other_result)
      confidence > other_result.confidence
    end

    private

    def raise_if_invalid_comparison(other_result)
      raise StandardError, '戦略不適用の結果は他の戦略と比較すべきではありません' if confidence == Confidence::DO_NOT_EXCHANGE

      raise StandardError, '完成役の結果は他の戦略と比較すべきではありません' if confidence == Confidence::ALREADY_COMPLETE

      raise StandardError, '保証された結果は他の戦略と比較すべきではありません' if confidence == Confidence::ONE_AWAY_GUARANTEED

      raise ArgumentError, '戦略不適用の結果と比較することはできません' if other_result.confidence == Confidence::DO_NOT_EXCHANGE

      raise ArgumentError, '完成役の結果と比較することはできません' if other_result.confidence == Confidence::ALREADY_COMPLETE

      raise ArgumentError, '保証された結果と比較することはできません' if other_result.confidence == Confidence::ONE_AWAY_GUARANTEED
    end
  end
end
