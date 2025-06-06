# frozen_string_literal: true

class HandSet::SameRankStrengthComparer
  class RemainingKindSetNumbersCompareBuilder
    class << self
      def from_high_cards(hand_set1, hand_set2)
        numbers1 = convert_numbers_for_comparer(hand_set1)
        sorted_numbers1 = sort_desc_by_strength(numbers1)

        numbers2 = convert_numbers_for_comparer(hand_set2)
        sorted_numbers2 = sort_desc_by_strength(numbers2)

        Compare.new(sorted_numbers1, sorted_numbers2)
      end

      def from_one_pair(hand_set1, hand_set2)
        remaining_numbers_proc = lambda do |hand_set|
          pair_numbers      = extract_numbers_by_count(hand_set, 2)
          excluded_numbers  = pair_numbers.take(1) # ← ワンペアなので 1 つだけ除外
          numbers           = convert_numbers_for_comparer(hand_set)
          remaining_numbers = numbers.reject { |n| excluded_numbers.include?(n) }

          sort_desc_by_strength(remaining_numbers)
        end

        numbers1 = remaining_numbers_proc.call(hand_set1)
        numbers2 = remaining_numbers_proc.call(hand_set2)

        Compare.new(numbers1, numbers2)
      end

      def from_two_pair(hand_set1, hand_set2)
        remaining_numbers_proc = lambda do |hand_set|
          extract_numbers_by_count(hand_set, 2)
          convert_numbers_for_comparer(hand_set)
          remaining_numbers = numbers1.reject { |n| excluded_numbers.include?(n) }.sort.reverse
          sort_desc_by_strength(remaining_numbers)
        end

        numbers1 = remaining_numbers_proc.call(hand_set1)
        numbers2 = convert_numbers_for_comparer(hand_set2)

        Compare.new(numbers1, numbers2)
      end

      def from_three_of_a_kind(hand_set1, hand_set2)
        remaining_numbers_proc = lambda do |hand_set|
          three_number = extract_numbers_by_count(hand_set, 3)
          excluded_numbers = three_number ? [three_number] : []
          numbers = convert_numbers_for_comparer(hand_set)
          remaining_numbers = numbers.reject { |number| excluded_numbers.include?(number) }
          sort_desc_by_strength(remaining_numbers)
        end

        numbers1 = remaining_numbers_proc.call(hand_set1)
        numbers2 = convert_numbers_for_comparer(hand_set2)

        Compare.new(numbers1, numbers2)
      end

      def from_four_of_a_kind(hand_set1, hand_set2)
        remaining_numbers_proc = lambda do |hand_set|
          four_number = extract_numbers_by_count(hand_set, 4)
          excluded_numbers = four_number ? [four_number] : []
          numbers = convert_numbers_for_comparer(hand_set)
          remaining_numbers = numbers.reject { |number| excluded_numbers.include?(number) }
          sort_desc_by_strength(remaining_numbers)
        end

        numbers1 = remaining_numbers_proc.call(hand_set1)
        numbers2 = remaining_numbers_proc.call(hand_set2)

        Compare.new(numbers1, numbers2)
      end

      private

      def extract_numbers_by_count(hand_set, kind)
        numbers = convert_numbers_for_comparer(hand_set)
        rank_counts = numbers.group_by(&:itself).transform_values(&:size)
        rank_counts.select { |_, count| count == kind }.keys.sort.reverse
      end

      def convert_numbers_for_comparer(hand_set)
        hand_set.cards.map { |card| HandSet::Evaluator::NUMBER_TO_VALUE[card.number] }
      end

      def sort_desc_by_strength(numbers)
        numbers.sort.reverse
      end
    end
  end
end
