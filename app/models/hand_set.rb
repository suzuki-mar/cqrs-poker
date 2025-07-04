# frozen_string_literal: true

class HandSet
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Comparable

  attr_reader :cards

  def self.rank_all
    HandSet::Rank::ALL
  end

  def self.rank_names
    HandSet::Rank::NAMES
  end

  def self.rank_japanese_name(rank)
    HandSet::Rank.japanese_name(rank)
  end

  def self.card?(obj)
    obj.is_a?(Card)
  end

  private_class_method :new

  def self.build(cards)
    raise ArgumentError, '手札が不正です' unless valid_cards?(cards)

    new(cards)
  end

  def self.build_card(card_str)
    Card.new(card_str)
  end

  def initialize(cards)
    @cards = cards.freeze
  end

  def as_json(_options = nil)
    cards.map(&:to_s)
  end

  def rebuild_after_exchange(discarded_card, new_card)
    raise ArgumentError, 'discarded_cardはCardでなければなりません' unless HandSet.card?(discarded_card)
    raise ArgumentError, 'new_cardはCardでなければなりません' unless HandSet.card?(new_card)

    # バージョン競合チェックの後でカードの存在チェックを行う
    index = cards.find_index { |card| card == discarded_card }
    return nil if index.nil?

    new_cards = @cards.dup
    new_cards[index] = new_card

    raise ArgumentError, 'Invalid hand' unless self.class.valid_cards?(new_cards)

    self.class.build(new_cards)
  end

  def evaluate
    HandSet::Evaluator.call(@cards)
  end

  def rank_name
    self.class.rank_names[evaluate]
  end

  def rank_strength
    self.class.rank_all.index(evaluate) || 0
  end

  def valid?
    self.class.valid_cards?(cards)
  end

  def fetch_by_number(number)
    raise ArgumentError, 'Invalid number' unless number.is_a?(Integer) &&
                                                 number.between?(1, ::GameRule::MAX_HAND_SIZE)

    cards[number - 1]
  end

  delegate :include?, to: :cards

  def <=>(other)
    raise ArgumentError, 'HandSet expected' unless other.is_a?(HandSet)

    # 役の強さを比較（高い数値ほど強い役）
    primary = rank_strength <=> other.rank_strength
    return primary unless primary.zero?

    HandSet::SameRankStrengthComparer.call(self, other)
  end

  def self.valid_cards?(cards)
    return false unless cards.is_a?(Array)
    return false unless cards.size == ::GameRule::MAX_HAND_SIZE

    cards.all?(&:valid?)
  end

  def self.valid_hand_set_format?(hand_set)
    hand_set.is_a?(Array) &&
      hand_set.size == ::GameRule::MAX_HAND_SIZE &&
      hand_set.all? { |c| c.present? && c.is_a?(String) }
  end
end
