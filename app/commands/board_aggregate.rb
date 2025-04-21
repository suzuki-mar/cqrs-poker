class BoardAggregate
  def initialize
    @deck = Deck.build
  end

  def draw_initial_hand
    deck.draw_initial_hand
  end

  def exchange(discarded_card)
    deck.exchange(discarded_card)
  end

  # 山札の残り枚数を返す
  def remaining_deck_count
    deck.size
  end

  # 山札のカード一覧を返す
  def deck_cards
    deck.cards
  end

  private

  attr_reader :deck
end
