# frozen_string_literal: true

class CardExchangedEvent
  def initialize(discarded_card, new_card)
    @discarded_card = discarded_card
    @new_card = new_card
  end

  def self.event_type
    'card_exchanged'
  end

  delegate :event_type, to: :class

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

  def self.from_store(store)
    event_data = JSON.parse(store.event_data, symbolize_names: true)
    discarded = HandSet.card_from_string(event_data[:discarded_card])
    new_c = HandSet.card_from_string(event_data[:new_card])
    new(discarded, new_c)
  end
end
