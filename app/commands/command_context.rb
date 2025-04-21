class CommandContext
  attr_reader :discarded_card

  def self.build_for_game_start
    new
  end

  def self.build_for_exchange(discarded_card)
    new(discarded_card: discarded_card)
  end

  private

  private_class_method :new

  def initialize(discarded_card: nil)
    @discarded_card = discarded_card
  end
end
