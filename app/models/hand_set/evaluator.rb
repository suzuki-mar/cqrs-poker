# frozen_string_literal: true

# RubyMineでは型が書いていないと扱われているがRBS側に型を書いている
#
class HandSet
  class Evaluator
    NUMBER_TO_VALUE = {
      'A' => 14,
      'K' => 13,
      'Q' => 12,
      'J' => 11,
      '10' => 10,
      '9' => 9,
      '8' => 8,
      '7' => 7,
      '6' => 6,
      '5' => 5,
      '4' => 4,
      '3' => 3,
      '2' => 2
    }.freeze

    def self.call(cards)
      new(cards).call
    end

    def initialize(cards)
      @cards = cards
    end

    def call
      raise ArgumentError, '手札が不正です' unless valid_hand?(@cards)

      rank_checks = build_rank_checks_map(@cards)
      found = rank_checks.find { |_, check| check.call }
      found ? found[0] : Rank::HIGH_CARD
    end

    private

    attr_reader :cards

    def royal_flush?
      flush? &&
        ranks.map { |n| NUMBER_TO_VALUE[n] }.sort == [10, 11, 12, 13, 14]
    end

    def straight_flush?
      straight? && flush?
    end

    delegate :four_of_a_kind?, to: :rank_combinations

    delegate :full_house?, to: :rank_combinations

    def flush?
      suits.uniq.size == 1
    end

    def straight?
      numbers = ranks.map { |n| NUMBER_TO_VALUE[n] }.sort
      return true if GameSetting.wheel_straight?(numbers)

      # 明示的に2つの整数値を取り出して比較することで型エラーを回避
      numbers.each_cons(2).all? do |pair|
        a, b = pair
        b && a && (b - a == 1)
      end
    end

    delegate :three_of_a_kind?, to: :rank_combinations

    def two_pair?
      rank_combinations.pair_count == 2
    end

    def one_pair?
      rank_combinations.pair_count == 1
    end

    # 役判定の一覧を返すだけのシンプルなメソッドのため、RubocopのAbcSize警告は無視します
    # rubocop:disable Metrics/AbcSize
    def build_rank_checks_map(_cards)
      {
        Rank::ROYAL_FLUSH => proc { royal_flush? },
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
    # rubocop:enable Metrics/AbcSize

    def suits
      cards.map(&:suit)
    end

    def rank_combinations
      RankCombinations.new(rank_counts.values)
    end

    def rank_counts
      ranks.group_by(&:itself).transform_values(&:size)
    end

    def ranks
      cards.map(&:number)
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
