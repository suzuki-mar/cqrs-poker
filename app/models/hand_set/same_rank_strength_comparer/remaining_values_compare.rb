# frozen_string_literal: true

module HandSet
  class SameRankStrengthComparer
    class RemainingValuesCompare
      def self.from_cards(hand_set1, hand_set2, used_values1, used_values2)
        values1 = hand_set1.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        values2 = hand_set2.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        remaining_values1 = values1.reject { |value| used_values1.include?(value) }.sort.reverse
        remaining_values2 = values2.reject { |value| used_values2.include?(value) }.sort.reverse
        new(remaining_values1, remaining_values2)
      end

      def self.from_high_cards(hand_set1, hand_set2)
        values1 = hand_set1.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }.sort.reverse
        values2 = hand_set2.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }.sort.reverse
        new(values1, values2)
      end

      def self.from_pair_values(hand_set1, hand_set2)
        pair_values1 = extract_pair_values(hand_set1)
        pair_values2 = extract_pair_values(hand_set2)
        new(pair_values1, pair_values2)
      end

      def self.from_three_of_a_kind_value(hand_set1, hand_set2)
        three_value1 = extract_three_of_a_kind_value(hand_set1)
        three_value2 = extract_three_of_a_kind_value(hand_set2)
        new(three_value1 ? [three_value1] : [], three_value2 ? [three_value2] : [])
      end

      def self.from_four_of_a_kind_value(hand_set1, hand_set2)
        four_value1 = extract_four_of_a_kind_value(hand_set1)
        four_value2 = extract_four_of_a_kind_value(hand_set2)
        new(four_value1 ? [four_value1] : [], four_value2 ? [four_value2] : [])
      end

      def self.from_straight_high_card(hand_set1, hand_set2)
        high_card1 = extract_straight_high_card(hand_set1)
        high_card2 = extract_straight_high_card(hand_set2)
        new([high_card1], [high_card2])
      end

      def self.from_cards_excluding_pairs(hand_set1, hand_set2)
        pairs1 = extract_pair_values(hand_set1)
        pairs2 = extract_pair_values(hand_set2)
        from_cards(hand_set1, hand_set2, pairs1, pairs2)
      end

      def initialize(values1, values2)
        @values1 = Array(values1).freeze
        @values2 = Array(values2).freeze
      end

      def compare
        values1.zip(values2).each do |v1, v2|
          return 1 if v2.nil? && !v1.nil?
          return -1 if v1.nil? && !v2.nil?
          return 0 if v1.nil? && v2.nil?

          comparison = v1 <=> v2
          return comparison unless comparison.zero?
        end

        0
      end

      def first_values
        [values1.first, values2.first]
      end

      def self.extract_pair_values(hand_set)
        values = hand_set.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        rank_counts = values.group_by(&:itself).transform_values(&:size)
        rank_counts.select { |_, count| count == 2 }.keys.sort.reverse
      end

      def self.extract_three_of_a_kind_value(hand_set)
        values = hand_set.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        rank_counts = values.group_by(&:itself).transform_values(&:size)
        rank_counts.find { |_, count| count == 3 }&.first
      end

      def self.extract_four_of_a_kind_value(hand_set)
        values = hand_set.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        rank_counts = values.group_by(&:itself).transform_values(&:size)
        rank_counts.find { |_, count| count == 4 }&.first
      end

      def self.extract_straight_high_card(hand_set)
        values = hand_set.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }.sort
        if values == [2, 3, 4, 5, 14]
          5
        else
          values.max
        end
      end

      private_class_method :extract_pair_values, :extract_three_of_a_kind_value,
                           :extract_four_of_a_kind_value, :extract_straight_high_card

      private

      attr_reader :values1, :values2
    end
  end
end
