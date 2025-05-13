# frozen_string_literal: true

class CardExchangedEvent
  def initialize(discarded_card, new_card)
    @discarded_card = discarded_card
    @new_card = new_card
    @event_id = nil
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

  def self.from_store(store)
    event_data = JSON.parse(store.event_data, symbolize_names: true)
    discarded = HandSet.build_card_for_command(event_data[:discarded_card])
    new_c = HandSet.build_card_for_command(event_data[:new_card])
    new(discarded, new_c)
  end

  def event_id
    @event_id || (raise 'event_idが未設定です')
  end

  def event_id=(value)
    raise 'event_idは一度しか設定できません' if !@event_id.nil? && @event_id != value

    @event_id ||= value
  end

  private

  attr_reader :discarded_card, :new_card
end
