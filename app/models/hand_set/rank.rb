# frozen_string_literal: true

class HandSet
  class Rank
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :name, :string

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
end
