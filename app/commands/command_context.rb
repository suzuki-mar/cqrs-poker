class CommandContext
  module Types
    GAME_START = :game_start
    EXCHANGE_CARD = :exchange_card
  end

  attr_reader :discarded_card, :type

  def self.build_for_game_start
    new(Types::GAME_START)
  end

  def self.build_for_exchange(discarded_card)
    new(Types::EXCHANGE_CARD, discarded_card)
  end

  private

  private_class_method :new

  def initialize(type, discarded_card = nil)
    @type = type
    @discarded_card = discarded_card
  end
end
