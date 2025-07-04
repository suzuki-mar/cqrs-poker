# typed: true

class ExchangeCardSelector
  class FourOfAKindStrategy
    def initialize(hand_set, trash_state)
      @hand_set = hand_set
      @trash_state = trash_state
    end

    def execute
      return EvaluationResult.build_do_not_exchange unless hand_set.evaluate == HandSet::Rank::THREE_OF_A_KIND

      three_card_number = find_three_card_number(hand_set)
      return EvaluationResult.build_do_not_exchange unless three_card_number

      trashed_same_numbers = count_trashed_cards_by_number(trash_state, three_card_number)

      return EvaluationResult.build_do_not_exchange if trashed_same_numbers >= 1

      build_exchange_result(hand_set, three_card_number)
    end

    private

    attr_reader :hand_set, :trash_state

    def find_three_card_number(hand_set)
      card_counts = hand_set.cards.group_by(&:number)
      three_card_entry = card_counts.find { |_, cards| cards.size == 3 }
      three_card_entry&.first
    end

    def build_exchange_result(hand_set, three_card_number)
      non_matching_cards = hand_set.cards.reject { |card| card.number == three_card_number }
      EvaluationResult.new(
        EvaluationResult::Confidence::MEDIUM,
        non_matching_cards
      )
    end

    def count_trashed_cards_by_number(_trash_state, _target_number)
      # 詳細なロジックは後で実装
      # 現在は仮実装として0を返す
      0
    end
  end
end
