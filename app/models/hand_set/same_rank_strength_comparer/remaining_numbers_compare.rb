# frozen_string_literal: true

class HandSet::SameRankStrengthComparer
  class RemainingNumbersCompare
    def initialize(values1, values2)
      @values1 = Array(values1).freeze
      @values2 = Array(values2).freeze
    end

    def compare
      values1.zip(values2).each do |v1, v2|
        nil_compare(v1, v2) if v1.nil? || v2.nil?

        comparison = v1 <=> v2
        return comparison unless comparison.zero?
      end

      0
    end

    private

    def nil_compare(v1, v2)
      return 1 if v2.nil? && !v1.nil?
      return -1 if v1.nil? && !v2.nil?
      return 0 if v1.nil? && v2.nil?

      nil
    end

    attr_reader :values1, :values2

    class << self
      def from_high_cards(hand_set1, hand_set2)
        values1 = hand_set1.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }.sort.reverse
        values2 = hand_set2.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }.sort.reverse
        new(values1, values2)
      end

      def from_one_pair(hand_set1, hand_set2)
        pair_values1 = extract_pair_values(hand_set1)
        pair_values2 = extract_pair_values(hand_set2)

        excluded_values1 = pair_values1.take(1) # ワンペアなので最初の1つのペア値のみ除外
        excluded_values2 = pair_values2.take(1)

        values1 = hand_set1.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        remaining_values1 = values1.reject { |value| excluded_values1.include?(value) }.sort.reverse

        values2 = hand_set2.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        remaining_values2 = values2.reject { |value| excluded_values2.include?(value) }.sort.reverse

        new(remaining_values1, remaining_values2)
      end

      def from_two_pair(hand_set1, hand_set2)
        pairs1 = extract_pair_values(hand_set1)
        pairs2 = extract_pair_values(hand_set2)

        values1 = hand_set1.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        remaining_values1 = values1.reject { |value| pairs1.include?(value) }.sort.reverse

        values2 = hand_set2.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        remaining_values2 = values2.reject { |value| pairs2.include?(value) }.sort.reverse

        new(remaining_values1, remaining_values2)
      end

      def from_three_of_a_kind(hand_set1, hand_set2)
        three_value1 = extract_three_of_a_kind_value(hand_set1)
        three_value2 = extract_three_of_a_kind_value(hand_set2)

        excluded_values1 = three_value1 ? [three_value1] : []
        excluded_values2 = three_value2 ? [three_value2] : []

        values1 = hand_set1.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        remaining_values1 = values1.reject { |value| excluded_values1.include?(value) }.sort.reverse

        values2 = hand_set2.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        remaining_values2 = values2.reject { |value| excluded_values2.include?(value) }.sort.reverse

        new(remaining_values1, remaining_values2)
      end

      def from_four_of_a_kind(hand_set1, hand_set2)
        four_value1 = extract_four_of_a_kind_value(hand_set1)
        four_value2 = extract_four_of_a_kind_value(hand_set2)

        excluded_values1 = four_value1 ? [four_value1] : []
        excluded_values2 = four_value2 ? [four_value2] : []

        values1 = hand_set1.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        remaining_values1 = values1.reject { |value| excluded_values1.include?(value) }.sort.reverse

        values2 = hand_set2.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        remaining_values2 = values2.reject { |value| excluded_values2.include?(value) }.sort.reverse

        new(remaining_values1, remaining_values2)
      end

      private

      def extract_pair_values(hand_set)
        values = hand_set.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        rank_counts = values.group_by(&:itself).transform_values(&:size)
        rank_counts.select { |_, count| count == 2 }.keys.sort.reverse
      end

      def extract_three_of_a_kind_value(hand_set)
        values = hand_set.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        rank_counts = values.group_by(&:itself).transform_values(&:size)
        rank_counts.find { |_, count| count == 3 }&.first
      end

      def extract_four_of_a_kind_value(hand_set)
        values = hand_set.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        rank_counts = values.group_by(&:itself).transform_values(&:size)
        rank_counts.find { |_, count| count == 4 }&.first
      end
    end
  end
end
