module Faker
  class HandGenerator
    HAND_PATTERNS = {
      one_pair:      ['♠A', '♥A', '♦3', '♣5', '♠7'],
      high_card:     ['♠A', '♥K', '♦3', '♣5', '♠7'],
      two_pair:      ['♠A', '♥A', '♦K', '♣K', '♠7'],
      straight_flush: ['♥2', '♥3', '♥4', '♥5', '♥6'],
      four_of_a_kind: ['♥7', '♦7', '♣7', '♠7', '♥2'],
      full_house:    ['♥8', '♦8', '♣8', '♠4', '♥4'],
      flush:         ['♥2', '♥5', '♥7', '♥9', '♥J'],
      straight:      ['♥2', '♦3', '♣4', '♠5', '♥6'],
      three_of_a_kind: ['♥7', '♦7', '♣7', '♠3', '♥5']
    }.freeze

    class << self
      def valid_hand
        ::Hand::Hand.new(5.times.map { Faker.valid_card })
      end

      HAND_PATTERNS.each do |name, cards|
        define_method("#{name}_hand") do
          create_hand(cards)
        end
      end

      private

      def create_hand(card_strings)
        cards = card_strings.map { |suit_rank| ::Card.new(suit_rank) }
        ::Hand::Hand.new(cards)
      end
    end
  end

  module Hand
    class << self
      def method_missing(method, *args, &block)
        if HandGenerator.respond_to?(method)
          HandGenerator.send(method, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method, include_private = false)
        HandGenerator.respond_to?(method) || super
      end
    end
  end
end 