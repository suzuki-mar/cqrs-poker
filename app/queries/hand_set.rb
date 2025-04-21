# frozen_string_literal: true

class HandSet
  module Rank
    HIGH_CARD = "HIGH_CARD"
    ONE_PAIR = "ONE_PAIR"
    TWO_PAIR = "TWO_PAIR"
    THREE_OF_A_KIND = "THREE_OF_A_KIND"
    STRAIGHT = "STRAIGHT"
    FLUSH = "FLUSH"
    FULL_HOUSE = "FULL_HOUSE"
    FOUR_OF_A_KIND = "FOUR_OF_A_KIND"
    STRAIGHT_FLUSH = "STRAIGHT_FLUSH"
    ROYAL_FLUSH = "ROYAL_FLUSH"

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
      HIGH_CARD => "ハイカード",
      ONE_PAIR => "ワンペア",
      TWO_PAIR => "ツーペア",
      THREE_OF_A_KIND => "スリーカード",
      STRAIGHT => "ストレート",
      FLUSH => "フラッシュ",
      FULL_HOUSE => "フルハウス",
      FOUR_OF_A_KIND => "フォーカード",
      STRAIGHT_FLUSH => "ストレートフラッシュ",
      ROYAL_FLUSH => "ロイヤルストレートフラッシュ"
    }.freeze

    def self.japanese_name(rank)
      NAMES[rank]
    end
  end

  CARDS_IN_HAND = 5

  attr_reader :cards

  private_class_method :new

  def self.generate_initial(cards)
    raise ArgumentError, "Invalid hand" unless valid_cards?(cards)
    new(cards)
  end

  def initialize(cards)
    @cards = cards.freeze
  end

  def rebuild_after_exchange(discarded_card, new_card)
    new_cards = cards.map do |card|
      card.to_s == discarded_card ? new_card : card
    end

    raise ArgumentError, "Invalid hand" unless self.class.valid_cards?(new_cards)
    self.class.new(new_cards)
  end

  def evaluate
    Evaluate.call(@cards)
  end

  def rank_name
    Rank::NAMES[evaluate]
  end

  def valid?
    self.class.valid_cards?(@cards)
  end

  private

  def self.valid_cards?(cards)
    return false unless cards.is_a?(Array)
    return false unless cards.size == CARDS_IN_HAND
    cards.all?(&:valid?)
  end
end
