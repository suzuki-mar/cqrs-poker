# frozen_string_literal: true

class GameStartedEvent
  def initialize(initial_hand)
    @initial_hand = initial_hand
    @event_id = nil
  end

  def self.event_type
    'game_started'
  end

  delegate :event_type, to: :class

  def to_event_data
    {
      initial_hand: initial_hand.cards,
      evaluate: initial_hand.evaluate
    }
  end

  # DB保存用
  def to_serialized_hash
    {
      initial_hand: initial_hand.cards.map(&:to_s),
      evaluate: initial_hand.evaluate
    }
  end

  def self.from_store(store)
    event_data = JSON.parse(store.event_data, symbolize_names: true)
    hand_data = event_data[:initial_hand]
    hand_cards = hand_data.map { |c| HandSet.build_card_for_query(c) }
    hand_set = HandSet.build(hand_cards)
    new(hand_set)
  end

  def self.from_event(event_record)
    event_data = JSON.parse(event_record.event_data, symbolize_names: true)
    initial_hand = event_data[:initial_hand]
    event = new(initial_hand)
    event.event_id = EventId.new(event_record.id) if event_record.respond_to?(:id) && event_record.id
    event
  end

  def self.from_event_data(event_data, id)
    hand_data = event_data[:initial_hand]
    hand_cards = hand_data.map { |c| HandSet.build_card_for_query(c) }
    hand_set = HandSet.build(hand_cards)
    event = new(hand_set)
    event.event_id = EventId.new(id)
    event
  end

  def event_id
    @event_id || (raise 'event_idが未設定です')
  end

  def event_id=(value)
    raise 'event_idは一度しか設定できません' if !@event_id.nil? && @event_id != value

    @event_id ||= value
  end

  private

  attr_reader :initial_hand
end
