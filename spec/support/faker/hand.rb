module Faker
  class Hand
    class << self
      def high_card
        create_hand([
          ::Card.new('♠A'), ::Card.new('♥K'), ::Card.new('♦3'), ::Card.new('♣5'), ::Card.new('♠7')
        ])
      end

      def one_pair
        create_hand([
          ::Card.new('♠A'), ::Card.new('♥A'), ::Card.new('♦3'), ::Card.new('♣5'), ::Card.new('♠7')
        ])
      end

      def two_pair
        create_hand([
          ::Card.new('♠A'), ::Card.new('♥A'), ::Card.new('♦K'), ::Card.new('♣K'), ::Card.new('♠7')
        ])
      end

      def three_of_a_kind
        create_hand([
          ::Card.new('♥7'), ::Card.new('♦7'), ::Card.new('♣7'), ::Card.new('♠3'), ::Card.new('♥5')
        ])
      end

      def straight
        create_hand([
          ::Card.new('♥2'), ::Card.new('♦3'), ::Card.new('♣4'), ::Card.new('♠5'), ::Card.new('♥6')
        ])
      end

      def flush
        create_hand([
          ::Card.new('♥2'), ::Card.new('♥5'), ::Card.new('♥7'), ::Card.new('♥9'), ::Card.new('♥J')
        ])
      end

      def full_house
        create_hand([
          ::Card.new('♥8'), ::Card.new('♦8'), ::Card.new('♣8'), ::Card.new('♠4'), ::Card.new('♥4')
        ])
      end

      def four_of_a_kind
        create_hand([
          ::Card.new('♥7'), ::Card.new('♦7'), ::Card.new('♣7'), ::Card.new('♠7'), ::Card.new('♥2')
        ])
      end

      def straight_flush
        create_hand([
          ::Card.new('♥2'), ::Card.new('♥3'), ::Card.new('♥4'), ::Card.new('♥5'), ::Card.new('♥6')
        ])
      end

      def royal_flush
        create_hand([
          ::Card.new('♥A'), ::Card.new('♥K'), ::Card.new('♥Q'), ::Card.new('♥J'), ::Card.new('♥10')
        ])
      end

      private

      def create_hand(cards)
        # Handは不正な形でインスタンスが生成されるのを避けるためnewを使えないようにしている
        ::HandSet.send(:new, cards)
      end
    end
  end
end
