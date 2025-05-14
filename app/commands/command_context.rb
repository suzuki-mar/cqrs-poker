class CommandContext
  module Types
    GAME_START = :game_start
    EXCHANGE_CARD = :exchange_card
    END_GAME = :end_game
  end

  attr_reader :discarded_card, :type, :game_number

  def self.build_for_game_start
    new(type: Types::GAME_START, discarded_card: nil, game_number: nil)
  end

  def self.build_for_exchange(discarded_card:, game_number:)
    new(type: Types::EXCHANGE_CARD, discarded_card: discarded_card, game_number: game_number)
  end

  def self.build_for_end_game(game_number:)
    new(type: Types::END_GAME, discarded_card: nil, game_number: game_number)
  end

  private

  private_class_method :new

  def initialize(type:, discarded_card: nil, game_number: nil)
    @type = type
    @discarded_card = discarded_card
    @game_number = game_number
  end
end
