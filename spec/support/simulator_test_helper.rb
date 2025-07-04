# frozen_string_literal: true

module SimulatorTestHelper
  def self.build_card(str)
    HandSet::Card.new(str)
  end

  def self.build_hand(card_strings)
    cards = card_strings.map { |str| build_card(str) }
    HandSet.build(cards)
  end
end
