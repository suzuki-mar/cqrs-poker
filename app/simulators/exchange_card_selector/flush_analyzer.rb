# typed: true

class ExchangeCardSelector
  class FlushAnalyzer
    def initialize(hand_set)
      @hand_set = hand_set
    end

    def matching_card_count
      # 同じスーツのカードの最大数を計算
      suits = hand_set.cards.group_by(&:suit)
      max_same_suit_cards = suits.values.max_by(&:size)
      return 0 unless max_same_suit_cards

      max_same_suit_cards.size
    end

    def exchange_cards_for_count(count)
      # 最大のスーツ以外のカードを交換対象として返す
      suits = hand_set.cards.group_by(&:suit)
      max_same_suit_cards = suits.values.max_by(&:size)
      return [] unless max_same_suit_cards

      exchange_cards = hand_set.cards - max_same_suit_cards
      exchange_cards.take(count)
    end

    private

    attr_reader :hand_set
  end
end
