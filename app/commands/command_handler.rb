# frozen_string_literal: true

class CommandHandler
  def handle(command)
    deck = Deck.instance
    command.new(deck).execute
  end
end
