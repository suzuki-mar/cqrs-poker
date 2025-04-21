class Trash
  def initialize
    @cards = []
  end

  def accept(card)
    cards << card
  end

  private

  attr_reader :cards
end
