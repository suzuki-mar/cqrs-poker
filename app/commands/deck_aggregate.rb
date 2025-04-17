class DeckAggregate
  attr_reader :cards

  def self.build
    new
  end

  def size
    cards.size
  end

  def draw_initial_hand
    drawn_cards = HandSet::CARDS_IN_HAND.times.map { draw }
    HandSet.generate_initial(drawn_cards)
  end

  private

  def initialize
    @cards = Card.generate_available([])
  end

  def draw
    raise ArgumentError, "デッキの残り枚数が不足しています" if @cards.empty?

    drawn_card = @cards.sample
    @cards = @cards - [ drawn_card ]
    drawn_card
  end
end
