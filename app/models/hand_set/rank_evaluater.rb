# frozen_string_literal: true

class HandSet
  module RankEvaluater
    module_function

    def call(cards)
      raise ArgumentError, '手札が不正です' unless valid_hand?(cards)

      rank_checks = build_rank_checks_map(cards)
      found = rank_checks.find { |_, check| check.call }
      found ? found[0] : Rank::HIGH_CARD
    end

    def build_rank_checks_map(cards)
      {
        Rank::STRAIGHT_FLUSH => proc { straight_flush?(cards) },
        Rank::FOUR_OF_A_KIND => proc { four_of_a_kind?(cards) },
        Rank::FULL_HOUSE => proc { full_house?(cards) },
        Rank::FLUSH => proc { flush?(cards) },
        Rank::STRAIGHT => proc { straight?(cards) },
        Rank::THREE_OF_A_KIND => proc { three_of_a_kind?(cards) },
        Rank::TWO_PAIR => proc { two_pair?(cards) },
        Rank::ONE_PAIR => proc { one_pair?(cards) }
      }
    end

    def one_pair?(cards)
      rank_combinations(cards).pair_count == 1
    end

    def two_pair?(cards)
      rank_combinations(cards).pair_count == 2
    end

    def three_of_a_kind?(cards)
      rank_combinations(cards).three_of_a_kind?
    end

    def four_of_a_kind?(cards)
      rank_combinations(cards).four_of_a_kind?
    end

    def full_house?(cards)
      rank_combinations(cards).full_house?
    end

    def flush?(cards)
      suits(cards).uniq.size == 1
    end

    def straight?(cards)
      sorted_ranks = ranks(cards).map(&:to_i).sort
      sorted_ranks.each_cons(2).all? { |a, b| b - a == 1 }
    end

    def straight_flush?(cards)
      straight?(cards) && flush?(cards)
    end

    def suits(cards)
      cards.map(&:suit)
    end

    def rank_combinations(cards)
      RankCombinations.new(rank_counts(cards).values)
    end

    def rank_counts(cards)
      ranks(cards).group_by(&:itself).transform_values(&:size)
    end

    def ranks(cards)
      cards.map(&:rank)
    end

    def valid_hand?(cards)
      cards.is_a?(Array) && cards.size == 5 && cards.all?(&:valid?)
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
