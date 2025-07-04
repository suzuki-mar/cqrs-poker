# typed: true

class ExchangeCardSelector
  class HighCardStrategy
    def initialize(hand_set, trash_state)
      @hand_set = hand_set
      @trash_state = trash_state
    end

    def execute
      return EvaluationResult.build_do_not_exchange unless hand_set.evaluate == HandSet::Rank::HIGH_CARD

      sorted_cards = hand_set.cards.sort_by { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
      exchange_cards = sorted_cards.take(4)

      EvaluationResult.new(
        EvaluationResult::Confidence::LOW,
        exchange_cards
      )
    end

    private

    attr_reader :hand_set, :trash_state
  end
end
