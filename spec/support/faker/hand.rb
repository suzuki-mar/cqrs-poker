module Faker
  class Hand
    class << self
      def high_card
        cards = [ Card.new('♠A'), Card.new('♥K'), Card.new('♦3'), Card.new('♣5'), Card.new('♠7') ]
        create_hand(cards)
      end

      def one_pair
        cards = [ Card.new('♠A'), Card.new('♥A'), Card.new('♦3'), Card.new('♣5'), Card.new('♠7') ]
        create_hand(cards)
      end

      def two_pair
        cards = [ Card.new('♠A'), Card.new('♥A'), Card.new('♦K'), Card.new('♣K'), Card.new('♠7') ]
        create_hand(cards)
      end

      def three_of_a_kind
        cards = [ Card.new('♥7'), Card.new('♦7'), Card.new('♣7'), Card.new('♠3'), Card.new('♥5') ]
        create_hand(cards)
      end

      def straight
        cards = [ Card.new('♥2'), Card.new('♦3'), Card.new('♣4'), Card.new('♠5'), Card.new('♥6') ]
        create_hand(cards)
      end

      def flush
        cards = [ Card.new('♥2'), Card.new('♥5'), Card.new('♥7'), Card.new('♥9'), Card.new('♥J') ]
        create_hand(cards)
      end

      def full_house
        cards = [ Card.new('♥8'), Card.new('♦8'), Card.new('♣8'), Card.new('♠4'), Card.new('♥4') ]
        create_hand(cards)
      end

      def four_of_a_kind
        cards = [ Card.new('♥7'), Card.new('♦7'), Card.new('♣7'), Card.new('♠7'), Card.new('♥2') ]
        create_hand(cards)
      end

      def straight_flush
        cards = [ Card.new('♥2'), Card.new('♥3'), Card.new('♥4'), Card.new('♥5'), Card.new('♥6') ]
        create_hand(cards)
      end

      def royal_flush
        cards = [ Card.new('♥A'), Card.new('♥K'), Card.new('♥Q'), Card.new('♥J'), Card.new('♥10') ]
        create_hand(cards)
      end

      private

      def create_hand(cards)
        # Handは不正な形でインスタンスが生成されるのを避けるためnewを使えないようにしている
        ::Hand.send(:new, cards)
      end
    end
  end
end
