# frozen_string_literal: true

class GameStartedEvent
  include AssignableIds

  def initialize(initial_hand, initial_deck_cards)
    @initial_hand = initial_hand
    @initial_deck_cards = initial_deck_cards
  end

  def self.event_type
    'game_started'
  end

  delegate :event_type, to: :class

  def to_event_data
    {
      initial_hand: initial_hand.cards,
      evaluate: initial_hand.evaluate,
      initial_deck: initial_deck_cards
    }
  end

  # DB保存用
  def to_serialized_hash
    event_data = to_event_data
    {
      initial_hand: event_data[:initial_hand].map(&:to_s),
      evaluate: event_data[:evaluate],
      initial_deck: event_data[:initial_deck].map(&:to_s)
    }
  end

  def self.from_store(store)
    event_data = JSON.parse(store.event_data, symbolize_names: true)
    hand_data = event_data[:initial_hand]
    hand_cards = hand_data.map { |c| HandSet.build_card(c.to_s) }
    hand_set = HandSet.build(hand_cards)

    deck_data = event_data[:initial_deck]
    deck_cards = deck_data.map { |c| HandSet.build_card(c.to_s) }

    new(hand_set, deck_cards)
  end

  def self.from_event(event_record)
    event_data = JSON.parse(event_record.event_data, symbolize_names: true)
    initial_hand_data = event_data[:initial_hand]
    initial_deck_data = event_data[:initial_deck]

    hand_cards = initial_hand_data.map { |c| HandSet.build_card(c.to_s) }
    hand_set = HandSet.build(hand_cards)

    deck_cards = initial_deck_data.map { |c| HandSet.build_card(c.to_s) }

    event = new(hand_set, deck_cards)

    EventFinalizer.execute(event, event_record)
  end

  def self.from_event_data(event_data, event_id, game_number)
    hand_data = event_data[:initial_hand]
    hand_cards = hand_data.map { |c| HandSet.build_card(c) }
    hand_set = HandSet.build(hand_cards)

    deck_data = event_data[:initial_deck]
    deck_cards = deck_data.map { |c| HandSet.build_card(c) }

    event = new(hand_set, deck_cards)
    event.assign_ids(event_id: event_id, game_number: game_number)
    event
  end

  def assign_ids(event_id:, game_number:)
    raise 'event_idは一度しか設定できません' if @event_id
    raise 'game_numberは一度しか設定できません' if @game_number

    @event_id = event_id
    @game_number = game_number
  end

  def event_id
    @event_id || (raise 'event_idが未設定です')
  end

  def game_number
    @game_number || (raise 'game_numberが未設定です')
  end

  private

  attr_reader :initial_hand, :initial_deck_cards
end
