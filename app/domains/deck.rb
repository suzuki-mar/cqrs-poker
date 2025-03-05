require "singleton"

class Deck
  include Singleton

  def initialize
    @cards = generate_cards
  end

  def draw(count)
    drawn_cards = @cards.take(count)
    @cards = @cards.drop(count)
    drawn_cards
  end

  def size
    @cards.size
  end

  def reset
    @cards = generate_cards
  end

  # デバッグ用に残りのカードをスートごとにグループ化して返す
  def remaining_cards
    @cards.group_by { |card| card.to_s[0] }
  end

  # 特定のスートのカードを取得
  def find_by_suit(suit)
    @cards.select { |card| card.to_s.start_with?(suit) }
  end

  # 特定のランクのカードを取得
  def find_by_rank(rank)
    @cards.select { |card| card.to_s.end_with?(rank) }
  end

  # 手札を生成するメソッドを追加
  def generate_hand
    Hand.generate_initial
  end

  private

  def generate_cards
    suits = [ "\u2660", "\u2665", "\u2666", "\u2663" ]
    ranks = [ "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K" ]

    cards = []
    suits.each do |suit|
      ranks.each do |rank|
        cards << Card.new("#{suit}#{rank}")
      end
    end

    cards
  end
end
