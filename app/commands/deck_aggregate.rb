class DeckAggregate
  def self.build
    new
  end

  def initialize
    reset
  end

  def draw(count)
    raise ArgumentError, "デッキの残り枚数が不足しています" if cards.size < count
    drawn_cards = cards.take(count)
    @cards = cards.drop(count)
    drawn_cards
  end

  def size
    cards.size
  end

  def reset
    @cards = generate_cards.shuffle
  end

  def generate_hand_set
    cards = draw(HandSet::CARDS_IN_HAND)
    HandSet.send(:new, cards)
  end

  private

  attr_reader :cards

  def generate_cards
    Card::VALID_SUITS.flat_map do |suit|
      Card::VALID_RANKS.map do |rank|
        Card.new("#{suit}#{rank}")
      end
    end
  end
end
