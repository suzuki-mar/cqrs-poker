# frozen_string_literal: true

require_relative 'assignable_ids'

class GameStartedEvent
  include AssignableIds

  def initialize(initial_hand)
    @initial_hand = initial_hand
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
    hand_cards = hand_data.map { |c| HandSet.build_card(c.to_s) }
    hand_set = HandSet.build(hand_cards)
    new(hand_set)
  end

  def self.from_event(event_record)
    event_data = JSON.parse(event_record.event_data, symbolize_names: true)
    initial_hand = event_data[:initial_hand]
    event = new(initial_hand)

    EventFinalizer.execute(event, event_record)
  end

  def self.from_event_data(event_data, event_id, game_number)
    hand_data = event_data[:initial_hand]
    hand_cards = hand_data.map { |c| HandSet.build_card(c) }
    hand_set = HandSet.build(hand_cards)
    event = new(hand_set)
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

  attr_reader :initial_hand
end
