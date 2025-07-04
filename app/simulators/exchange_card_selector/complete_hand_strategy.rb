# typed: true

class ExchangeCardSelector
  class CompleteHandStrategy
    def initialize(hand_set, trash_state)
      @hand_set = hand_set
      @trash_state = trash_state
    end

    def execute
      current_rank = hand_set.evaluate

      return EvaluationResult.build_no_exchange_needed if straight_or_flush_completed?(current_rank)

      straight_analyzer = StraightAnalyzer.new(hand_set)
      flush_analyzer = FlushAnalyzer.new(hand_set)

      straight_evaluation = evaluate_with_analyzer(straight_analyzer)
      flush_evaluation = evaluate_with_analyzer(flush_analyzer)

      best_evaluation = [straight_evaluation, flush_evaluation].compact.max_by(&:confidence)

      best_evaluation || EvaluationResult.build_do_not_exchange
    end

    private

    attr_reader :hand_set, :trash_state

    def straight_or_flush_completed?(rank)
      [
        HandSet::Rank::STRAIGHT,
        HandSet::Rank::FLUSH,
        HandSet::Rank::STRAIGHT_FLUSH,
        HandSet::Rank::ROYAL_FLUSH
      ].include?(rank)
    end

    def evaluate_with_analyzer(analyzer)
      matching_count = analyzer.matching_card_count
      not_applicable = matching_count < 2

      return nil if not_applicable

      exchange_count = GameRule::MAX_HAND_SIZE - matching_count
      exchange_cards = analyzer.exchange_cards_for_count(exchange_count)

      return evaluate_with_pair_check(exchange_cards) if matching_count == 2

      confidence = matching_count == 4 ? EvaluationResult::Confidence::HIGH : EvaluationResult::Confidence::MEDIUM
      EvaluationResult.new(confidence, exchange_cards)
    end

    def evaluate_with_pair_check(exchange_cards)
      card_numbers = hand_set.cards.group_by(&:number)
      has_pair = card_numbers.any? { |_, cards| cards.size >= 2 }

      return EvaluationResult.build_do_not_exchange if has_pair

      EvaluationResult.new(EvaluationResult::Confidence::LOW, exchange_cards)
    end
  end
end
