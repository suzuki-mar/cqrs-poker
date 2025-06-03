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
      remaining_values = RemainingValuesCompare.from_high_cards(hand_set1, hand_set2)
      remaining_values.compare
    end

    def compare_one_pair
      pair_values = RemainingValuesCompare.from_pair_values(hand_set1, hand_set2)
      comparison = pair_values.compare
      return comparison unless comparison.zero?

      first_pair_values = pair_values.first_values
      remaining_values = RemainingValuesCompare.from_cards(hand_set1, hand_set2, [first_pair_values[0]],
                                                           [first_pair_values[1]])
      remaining_values.compare
    end

    def compare_two_pair
      pair_values = RemainingValuesCompare.from_pair_values(hand_set1, hand_set2)
      comparison = pair_values.compare
      return comparison unless comparison.zero?

      # 2ペアの場合、全てのペア値を除外してキッカーを比較する
      remaining_values = RemainingValuesCompare.from_cards_excluding_pairs(hand_set1, hand_set2)
      remaining_values.compare
    end

    def compare_three_of_a_kind
      three_values = RemainingValuesCompare.from_three_of_a_kind_value(hand_set1, hand_set2)
      comparison = three_values.compare
      return comparison unless comparison.zero?

      first_three_values = three_values.first_values
      remaining_values = RemainingValuesCompare.from_cards(hand_set1, hand_set2, [first_three_values[0]],
                                                           [first_three_values[1]])
      remaining_values.compare
    end

    def compare_straight
      high_values = RemainingValuesCompare.from_straight_high_card(hand_set1, hand_set2)
      high_values.compare
    end

    def compare_full_house
      three_values = RemainingValuesCompare.from_three_of_a_kind_value(hand_set1, hand_set2)
      comparison = three_values.compare
      return comparison unless comparison.zero?

      pair_values = RemainingValuesCompare.from_pair_values(hand_set1, hand_set2)
      pair_values.compare
    end

    def compare_four_of_a_kind
      four_values = RemainingValuesCompare.from_four_of_a_kind_value(hand_set1, hand_set2)
      comparison = four_values.compare
      return comparison unless comparison.zero?

      first_four_values = four_values.first_values
      remaining_values = RemainingValuesCompare.from_cards(hand_set1, hand_set2, [first_four_values[0]],
                                                           [first_four_values[1]])
      remaining_values.compare
    end
  end
end
