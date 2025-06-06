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
      method_maps = {
        Rank::HIGH_CARD => :compare_high_cards,
        Rank::FLUSH => :compare_high_cards, # HIGH_CARD と同じロジック
        Rank::ONE_PAIR => :compare_one_pair,
        Rank::TWO_PAIR => :compare_two_pair,
        Rank::THREE_OF_A_KIND => :compare_three_of_a_kind,
        Rank::STRAIGHT => :compare_straight,
        Rank::STRAIGHT_FLUSH => :compare_straight, # STRAIGHT と同じロジック
        Rank::ROYAL_FLUSH => :compare_straight, # STRAIGHT と同じロジック
        Rank::FULL_HOUSE => :compare_full_house,
        Rank::FOUR_OF_A_KIND => :compare_four_of_a_kind
      }

      rank = hand_set1.evaluate
      method_name = method_maps[rank]
      raise "不正な役が渡された rank:#{rank} hand_set:#{hand_set1}" if method_name.nil?

      # 戻り値がuntypedなのですぐにreturnせずにタイプを指定してからreturnしている
      # rubocop:disable Style/RedundantAssignment
      # @type var result: Integer
      result = send(method_maps[rank])
      result
      # rubocop:enable Style/RedundantAssignment
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
