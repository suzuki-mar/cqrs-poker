# frozen_string_literal: true

require_relative 'hand_set/evaluate'

class HandSet
  module Rank
    HIGH_CARD = 'HIGH_CARD'
    ONE_PAIR = 'ONE_PAIR'
    TWO_PAIR = 'TWO_PAIR'
    THREE_OF_A_KIND = 'THREE_OF_A_KIND'
    STRAIGHT = 'STRAIGHT'
    FLUSH = 'FLUSH'
    FULL_HOUSE = 'FULL_HOUSE'
    FOUR_OF_A_KIND = 'FOUR_OF_A_KIND'
    STRAIGHT_FLUSH = 'STRAIGHT_FLUSH'
    ROYAL_FLUSH = 'ROYAL_FLUSH'

    ALL = [
      HIGH_CARD,
      ONE_PAIR,
      TWO_PAIR,
      THREE_OF_A_KIND,
      STRAIGHT,
      FLUSH,
      FULL_HOUSE,
      FOUR_OF_A_KIND,
      STRAIGHT_FLUSH,
      ROYAL_FLUSH
    ].freeze

    NAMES = {
      HIGH_CARD => 'ハイカード',
      ONE_PAIR => 'ワンペア',
      TWO_PAIR => 'ツーペア',
      THREE_OF_A_KIND => 'スリーカード',
      STRAIGHT => 'ストレート',
      FLUSH => 'フラッシュ',
      FULL_HOUSE => 'フルハウス',
      FOUR_OF_A_KIND => 'フォーカード',
      STRAIGHT_FLUSH => 'ストレートフラッシュ',
      ROYAL_FLUSH => 'ロイヤルストレートフラッシュ'
    }.freeze

    def self.japanese_name(rank)
      NAMES[rank]
    end
  end

  attr_reader :cards

  private_class_method :new

  def self.build(cards)
    raise ArgumentError, '手札が不正です' unless HandSet.valid_cards?(cards)

    new(cards)
  end

  def initialize(cards)
    @cards = cards.freeze
  end

  def rebuild_after_exchange(discarded_card, new_card)
    raise ArgumentError, 'discarded_cardはCardでなければなりません' unless discarded_card.is_a?(Card)
    raise ArgumentError, 'new_cardはCardでなければなりません' unless new_card.is_a?(Card)

    index = @cards.find_index { |card| card == discarded_card }
    raise ArgumentError, '交換対象のカードが手札に存在しません' if index.nil?

    new_cards = @cards.dup
    new_cards[index] = new_card

    raise ArgumentError, 'Invalid hand' unless HandSet.valid_cards?(new_cards)

    HandSet.build(new_cards)
  end

  def evaluate
    HandSet::Evaluate.call(@cards)
  end

  def rank_name
    Rank::NAMES[evaluate]
  end

  def valid?
    HandSet.valid_cards?(@cards)
  end

  def fetch_by_number(number)
    raise ArgumentError, 'Invalid number' unless number.is_a?(Integer) &&
                                                 number.between?(1, ::PlayerHandState::MAX_HAND_SIZE)

    @cards[number - 1]
  end

  delegate :include?, to: :@cards

  def self.valid_cards?(cards)
    return false unless cards.is_a?(Array)
    return false unless cards.size == ::PlayerHandState::MAX_HAND_SIZE

    cards.all?(&:valid?)
  end
end
