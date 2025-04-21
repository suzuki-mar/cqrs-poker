# frozen_string_literal: true

class HandSet
  class Evaluate
    def self.call(cards)
      new.call(cards)
    end

    def call(cards)
      @cards = cards

      unless valid_hand?(@cards)
        raise ArgumentError, "手札が不正です"
      end

      if straight_flush?
        Rank::STRAIGHT_FLUSH
      elsif four_of_a_kind?
        Rank::FOUR_OF_A_KIND
      elsif full_house?
        Rank::FULL_HOUSE
      elsif flush?
        Rank::FLUSH
      elsif straight?
        Rank::STRAIGHT
      elsif three_of_a_kind?
        Rank::THREE_OF_A_KIND
      elsif two_pair?
        Rank::TWO_PAIR
      elsif one_pair?
        Rank::ONE_PAIR
      else
        Rank::HIGH_CARD
      end
    end

    private

    def one_pair?
      rank_combinations.pair_count == 1
    end

    def two_pair?
      rank_combinations.pair_count == 2
    end

    def three_of_a_kind?
      rank_combinations.three_of_a_kind?
    end

    def four_of_a_kind?
      rank_combinations.four_of_a_kind?
    end

    def full_house?
      rank_combinations.full_house?
    end

    def flush?
      suits.uniq.size == 1
    end

    def straight?
      sorted_ranks = ranks.map(&:to_i).sort
      is_consecutive = ->(numbers) {
        numbers.each_cons(2).all? { |current, next_number| next_number - current == 1 }
      }
      is_consecutive.call(sorted_ranks)
    end

    def straight_flush?
      straight? && flush?
    end

    def suits
      @cards.map(&:suit)
    end

    def rank_combinations
      RankCombinations.new(rank_counts.values)
    end

    def rank_counts
      ranks.group_by(&:itself).transform_values(&:size)
    end

    def ranks
      @cards.map(&:rank)
    end

    def valid_hand?(cards)
      return false unless cards.is_a?(Array)
      return false unless cards.size == 5
      cards.all?(&:valid?)
    end

    class RankCombinations
      def initialize(rank_counts)
        @groups = rank_counts.tally
      end

      def pair_count
        @groups[2] || 0
      end

      def three_of_a_kind?
        @groups[3] == 1
      end

      def four_of_a_kind?
        @groups[4] == 1
      end

      def full_house?
        three_of_a_kind? && pair_count == 1
      end
    end
  end
end
