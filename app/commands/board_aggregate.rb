class BoardAggregate
  def initialize
    @deck = Deck.build
    @trash = Trash.new
  end

  def self.load_from_events(events)
    aggregate = new
    events.each { |event| aggregate.apply(event) }
    aggregate
  end

  def apply(event)
    case event
    when GameStartedEvent
      event.initial_hand.cards.each do |card|
        deck.remove(card)
      end
    when CardExchangedEvent
      deck.remove(event.new_card)
    end
  end

  def draw_initial_hand
    deck.draw_initial_hand
  end

  def exchange(discarded_card)
    discard_to_trash(discarded_card)
    deck.exchange(discarded_card)
  end

  # カードを捨て札置き場に捨てる
  def discard_to_trash(card)
    trash.accept(card)
  end

  private

  attr_reader :deck, :trash
end
