# frozen_string_literal: true

require_relative 'assignable_ids'

class CardExchangedEvent
  include AssignableIds

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

  def self.from_event(store)
    event_data = JSON.parse(store.event_data, symbolize_names: true)
    discarded = HandSet.build_card_for_command(event_data[:discarded_card])
    new_c = HandSet.build_card_for_command(event_data[:new_card])
    event = new(discarded, new_c)
    if store.respond_to?(:id) && store.id && store.respond_to?(:game_number) && store.game_number
      event.assign_ids(event_id: EventId.new(store.id), game_number: GameNumber.new(store.game_number))
    end
    event
  end

  def self.from_event_data(event_data, event_id, game_number)
    discarded = HandSet.build_card_for_command(event_data[:discarded_card])
    new_c = HandSet.build_card_for_command(event_data[:new_card])
    event = new(discarded, new_c)
    event.assign_ids(event_id: event_id, game_number: game_number)
    event
  end

  private

  attr_reader :discarded_card, :new_card
end
