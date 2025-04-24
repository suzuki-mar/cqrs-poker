# frozen_string_literal: true

class CardExchangedEvent
  EVENT_TYPE = "card_exchanged"

  def initialize(discarded_card, new_card)
    @discarded_card = discarded_card
    @new_card = new_card
  end

  def event_type
    EVENT_TYPE
  end

  def event_type_name
    EVENT_TYPE
  end

  def to_event_data
    {
      discarded_card: discarded_card,
      new_card: new_card
    }
  end

  # DB保存用
  def to_serialized_hash
    {
      discarded_card: discarded_card.to_s,
      new_card: new_card.to_s
    }
  end

  attr_reader :discarded_card, :new_card

  private
end
