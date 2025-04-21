# frozen_string_literal: true

class CardExchangedEvent
  def initialize(discarded_card, new_card)
    @discarded_card = discarded_card
    @new_card = new_card
  end

  def event_type
    "card_exchanged"
  end

  def event_data
    {
      discarded_card: discarded_card.to_s,
      new_card: new_card.to_s
    }
  end

  private

  attr_reader :discarded_card, :new_card
end
