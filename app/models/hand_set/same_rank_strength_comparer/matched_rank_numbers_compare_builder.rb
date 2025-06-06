# frozen_string_literal: true

class HandSet::SameRankStrengthComparer
  class MatchedRankNumbersCompareBuilder
    class << self
      def from_pair_hand_set(hand_set1, hand_set2)
        numbers1 = extract_numbers_by_kind(hand_set1, 2)
        numbers2 = extract_numbers_by_kind(hand_set2, 2)
        Compare.new(numbers1, numbers2)
      end

      def from_three_of_a_kind_hand_set(hand_set1, hand_set2)
        number1 = extract_numbers_by_kind(hand_set1, 3)
        number2 = extract_numbers_by_kind(hand_set2, 3)

        Compare.new(number1 ? [number1] : [], number2 ? [number2] : [])
      end

      def from_four_of_a_kind_hand_set(hand_set1, hand_set2)
        number1 = extract_numbers_by_kind(hand_set1, 4)
        number2 = extract_numbers_by_kind(hand_set2, 4)

        Compare.new(number1 ? [number1] : [], number2 ? [number2] : [])
      end

      def from_straight_hand_set(hand_set1, hand_set2)
        extract_straight_high_card = lambda do |hand_set|
          numbers = hand_set.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }.sort
          GameSetting.wheel_straight?(numbers) ? GameSetting::WHEEL_HIGH_CARD_INT : numbers.max
        end

        Compare.new(
          [extract_straight_high_card.call(hand_set1)],
          [extract_straight_high_card.call(hand_set2)]
        )
      end

      private

      def extract_numbers_by_kind(hand_set, kind)
        numbers = hand_set.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
        rank_counts = numbers.group_by(&:itself).transform_values(&:size)
        rank_counts.select { |_, count| count == kind }.keys.sort.reverse
      end
    end
  end
end
