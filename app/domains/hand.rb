module Hand
  module Rank
    HIGH_CARD = 'HIGH_CARD'
    ONE_PAIR = 'ONE_PAIR'
    TWO_PAIR = 'TWO_PAIR'
    THREE_OF_A_KIND = 'THREE_OF_A_KIND'
    STRAIGHT = 'STRAIGHT'
    FLUSH = 'FLUSH'
    FULL_HOUSE = 'FULL_HOUSE'
    FOUR_OF_A_KIND = 'FOUR_OF_A_KIND'
    STRAIGHT_FLUSH = 'STRAIGHT_FLUSH'
    ROYAL_FLUSH = 'ROYAL_FLUSH'

    ALL = [
      HIGH_CARD,      # ハイカード
      ONE_PAIR,       # ワンペア
      TWO_PAIR,       # ツーペア
      THREE_OF_A_KIND, # スリーカード
      STRAIGHT,       # ストレート
      FLUSH,          # フラッシュ
      FULL_HOUSE,     # フルハウス
      FOUR_OF_A_KIND, # フォーカード
      STRAIGHT_FLUSH, # ストレートフラッシュ
      ROYAL_FLUSH     # ロイヤルストレートフラッシュ
    ].freeze
  end

  class Evaluator
    def initialize(cards)
      @cards = cards
    end

    def evaluate
      # TODO: 役の評価ロジックを実装
      Rank::HIGH_CARD
    end
  end
end 