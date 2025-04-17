# frozen_string_literal: true

class GameStartCommand
  def self.execute(deck)
    new(deck).execute
  end

  private :initialize

  def initialize(deck)
    @deck = deck
  end

  def execute
    raise InvalidCommand, "ゲームはすでに開始されています" if GameState.exists?(status: :started)

    initial_hand = deck.draw_initial_hand
    game_state = GameState.new(status: :started)
    game_state.assign_hand_number_from_set(initial_hand)
    game_state.save!

    GameStartedEvent.new(initial_hand)
  end

  private

  attr_reader :deck
end
