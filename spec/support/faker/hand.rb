module Faker
  class Hand
    class << self
      def high_card
        create_hand([
                      HandSet.card_from_string('♠A'), HandSet.card_from_string('♥K'), HandSet.card_from_string('♦3'), HandSet.card_from_string('♣5'), HandSet.card_from_string('♠7')
                    ])
      end

      def one_pair
        create_hand([
                      HandSet.card_from_string('♠A'), HandSet.card_from_string('♥A'), HandSet.card_from_string('♦3'), HandSet.card_from_string('♣5'), HandSet.card_from_string('♠7')
                    ])
      end

      def two_pair
        create_hand([
                      HandSet.card_from_string('♠A'), HandSet.card_from_string('♥A'), HandSet.card_from_string('♦K'), HandSet.card_from_string('♣K'), HandSet.card_from_string('♠7')
                    ])
      end

      def three_of_a_kind
        create_hand([
                      HandSet.card_from_string('♥7'), HandSet.card_from_string('♦7'), HandSet.card_from_string('♣7'), HandSet.card_from_string('♠3'), HandSet.card_from_string('♥5')
                    ])
      end

      def straight
        create_hand([
                      HandSet.card_from_string('♥2'), HandSet.card_from_string('♦3'), HandSet.card_from_string('♣4'), HandSet.card_from_string('♠5'), HandSet.card_from_string('♥6')
                    ])
      end

      def flush
        create_hand([
                      HandSet.card_from_string('♥2'), HandSet.card_from_string('♥5'), HandSet.card_from_string('♥7'), HandSet.card_from_string('♥9'), HandSet.card_from_string('♥J')
                    ])
      end

      def full_house
        create_hand([
                      HandSet.card_from_string('♥8'), HandSet.card_from_string('♦8'), HandSet.card_from_string('♣8'), HandSet.card_from_string('♠4'), HandSet.card_from_string('♥4')
                    ])
      end

      def four_of_a_kind
        create_hand([
                      HandSet.card_from_string('♥7'), HandSet.card_from_string('♦7'), HandSet.card_from_string('♣7'), HandSet.card_from_string('♠7'), HandSet.card_from_string('♥2')
                    ])
      end

      def straight_flush
        create_hand([
                      HandSet.card_from_string('♥2'), HandSet.card_from_string('♥3'), HandSet.card_from_string('♥4'), HandSet.card_from_string('♥5'), HandSet.card_from_string('♥6')
                    ])
      end

      def royal_flush
        create_hand([
                      HandSet.card_from_string('♥A'), HandSet.card_from_string('♥K'), HandSet.card_from_string('♥Q'), HandSet.card_from_string('♥J'), HandSet.card_from_string('♥10')
                    ])
      end

      def from_cards(cards)
        HandSet.build(cards)
      end

      def not_in_hand_card(hand_set)
        raise ArgumentError, 'HandSetインスタンスを渡してください' unless hand_set.is_a?(HandSet)

        available = HandSet::Card.generate_available(hand_set.cards)
        available.sample
      end

      private

      def create_hand(cards)
        HandSet.send(:new, cards)
      end
    end
  end
end
