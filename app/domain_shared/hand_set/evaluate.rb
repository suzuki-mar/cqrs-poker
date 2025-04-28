# frozen_string_literal: true

class HandSet
  class Evaluate
    def self.call(cards)
      new.call(cards)
    end

    def call(cards)
      @cards = cards

      raise ArgumentError, '手札が不正です' unless valid_hand?(@cards)

      rank_checks = build_rank_checks_map
      found = rank_checks.find { |_, check| check.call }
      found ? found[0] : Rank::HIGH_CARD
    end

    private

    def build_rank_checks_map
      {
        Rank::STRAIGHT_FLUSH => proc { straight_flush? },
        Rank::FOUR_OF_A_KIND => proc { four_of_a_kind? },
        Rank::FULL_HOUSE => proc { full_house? },
        Rank::FLUSH => proc { flush? },
        Rank::STRAIGHT => proc { straight? },
        Rank::THREE_OF_A_KIND => proc { three_of_a_kind? },
        Rank::TWO_PAIR => proc { two_pair? },
        Rank::ONE_PAIR => proc { one_pair? }
      }
    end

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
      is_consecutive = lambda { |numbers|
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
