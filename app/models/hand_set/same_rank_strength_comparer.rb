# frozen_string_literal: true

class HandSet
  class SameRankStrengthComparer
    def self.call(hand_set1, hand_set2)
      new(hand_set1, hand_set2).call
    end

    def initialize(hand_set1, hand_set2)
      @hand_set1 = hand_set1
      @hand_set2 = hand_set2
    end

    private_class_method :new

    def call
      rank = hand_set1.evaluate

      case rank
      when Rank::HIGH_CARD
        compare_high_cards
      when Rank::ONE_PAIR
        compare_one_pair
      when Rank::TWO_PAIR
        compare_two_pair
      when Rank::THREE_OF_A_KIND
        compare_three_of_a_kind
      when Rank::STRAIGHT
        compare_straight
      when Rank::FLUSH
        compare_high_cards
      when Rank::FULL_HOUSE
        compare_full_house
      when Rank::FOUR_OF_A_KIND
        compare_four_of_a_kind
      when Rank::STRAIGHT_FLUSH, Rank::ROYAL_FLUSH
        compare_straight
      else
        0
      end
    end

    private

    attr_reader :hand_set1, :hand_set2

    def compare_high_cards
      remaining_values = RemainingKindSetNumbersCompareBuilder.from_high_cards(hand_set1, hand_set2)
      remaining_values.compare
    end

    def compare_one_pair
      pair_values = MatchedRankNumbersCompareBuilder.from_pair_hand_set(hand_set1, hand_set2)
      comparison = pair_values.compare
      return comparison unless comparison.zero?

      remaining_values = RemainingKindSetNumbersCompareBuilder.from_one_pair(hand_set1, hand_set2)
      remaining_values.compare
    end

    def compare_two_pair
      pair_values = MatchedRankNumbersCompareBuilder.from_pair_hand_set(hand_set1, hand_set2)
      comparison = pair_values.compare
      return comparison unless comparison.zero?

      remaining_values = RemainingKindSetNumbersCompareBuilder.from_two_pair(hand_set1, hand_set2)
      remaining_values.compare
    end

    def compare_three_of_a_kind
      three_values = MatchedRankNumbersCompareBuilder.from_three_of_a_kind_hand_set(hand_set1, hand_set2)
      comparison = three_values.compare
      return comparison unless comparison.zero?

      remaining_values = RemainingKindSetNumbersCompareBuilder.from_three_of_a_kind(hand_set1, hand_set2)
      remaining_values.compare
    end

    def compare_straight
      high_values = MatchedRankNumbersCompareBuilder.from_straight_hand_set(hand_set1, hand_set2)
      high_values.compare
    end

    def compare_full_house
      three_values = MatchedRankNumbersCompareBuilder.from_three_of_a_kind_hand_set(hand_set1, hand_set2)
      comparison = three_values.compare
      return comparison unless comparison.zero?

      pair_values = MatchedRankNumbersCompareBuilder.from_pair_hand_set(hand_set1, hand_set2)
      pair_values.compare
    end

    def compare_four_of_a_kind
      four_values = MatchedRankNumbersCompareBuilder.from_four_of_a_kind_hand_set(hand_set1, hand_set2)
      comparison = four_values.compare
      return comparison unless comparison.zero?

      remaining_values = RemainingKindSetNumbersCompareBuilder.from_four_of_a_kind(hand_set1, hand_set2)
      remaining_values.compare
    end
  end
end
