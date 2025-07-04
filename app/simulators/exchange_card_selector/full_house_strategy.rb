# typed: true

class ExchangeCardSelector
  class FullHouseStrategy
    def initialize(hand_set, trash_state)
      @hand_set = hand_set
      @trash_state = trash_state
    end

    def execute
      card_counts = hand_set.cards.group_by(&:number)
      pairs = card_counts.select { |_, cards| cards.size >= 2 }

      return EvaluationResult.build_do_not_exchange if pairs.empty?

      current_rank = hand_set.evaluate
      return EvaluationResult.build_no_exchange_needed if current_rank == HandSet::Rank::FULL_HOUSE

      build_exchange_strategy_result(pairs)
    end

    private

    attr_reader :hand_set, :trash_state

    def build_exchange_strategy_result(pairs)
      paired_cards = pairs.values.flatten
      exchange_cards = hand_set.cards - paired_cards

      confidence = determine_confidence(pairs, exchange_cards)

      EvaluationResult.new(
        confidence,
        exchange_cards
      )
    end

    def determine_confidence(pairs, exchange_cards)
      if pairs.size == 2 && exchange_cards.size == 1
        EvaluationResult::Confidence::HIGH
      elsif pairs.size == 1 && pairs.values.first.size == 2
        EvaluationResult::Confidence::LOW
      else
        EvaluationResult::Confidence::MEDIUM
      end
    end
  end
end
