module Faker
  class Hand
    class << self
      def high_card
        create_hand([
                      HandSet.build_card_for_command('♠A'), HandSet.build_card_for_command('♥K'), HandSet.build_card_for_command('♦3'), HandSet.build_card_for_command('♣5'), HandSet.build_card_for_command('♠7')
                    ])
      end

      def one_pair
        create_hand([
                      HandSet.build_card_for_command('♠A'), HandSet.build_card_for_command('♥A'), HandSet.build_card_for_command('♦3'), HandSet.build_card_for_command('♣5'), HandSet.build_card_for_command('♠7')
                    ])
      end

      def two_pair
        create_hand([
                      HandSet.build_card_for_command('♠A'), HandSet.build_card_for_command('♥A'), HandSet.build_card_for_command('♦K'), HandSet.build_card_for_command('♣K'), HandSet.build_card_for_command('♠7')
                    ])
      end

      def three_of_a_kind
        create_hand([
                      HandSet.build_card_for_command('♥7'), HandSet.build_card_for_command('♦7'), HandSet.build_card_for_command('♣7'), HandSet.build_card_for_command('♠3'), HandSet.build_card_for_command('♥5')
                    ])
      end

      def straight
        create_hand([
                      HandSet.build_card_for_command('♥2'), HandSet.build_card_for_command('♦3'), HandSet.build_card_for_command('♣4'), HandSet.build_card_for_command('♠5'), HandSet.build_card_for_command('♥6')
                    ])
      end

      def flush
        create_hand([
                      HandSet.build_card_for_command('♥2'), HandSet.build_card_for_command('♥5'), HandSet.build_card_for_command('♥7'), HandSet.build_card_for_command('♥9'), HandSet.build_card_for_command('♥J')
                    ])
      end

      def full_house
        create_hand([
                      HandSet.build_card_for_command('♥8'), HandSet.build_card_for_command('♦8'), HandSet.build_card_for_command('♣8'), HandSet.build_card_for_command('♠4'), HandSet.build_card_for_command('♥4')
                    ])
      end

      def four_of_a_kind
        create_hand([
                      HandSet.build_card_for_command('♥7'), HandSet.build_card_for_command('♦7'), HandSet.build_card_for_command('♣7'), HandSet.build_card_for_command('♠7'), HandSet.build_card_for_command('♥2')
                    ])
      end

      def straight_flush
        create_hand([
                      HandSet.build_card_for_command('♥2'), HandSet.build_card_for_command('♥3'), HandSet.build_card_for_command('♥4'), HandSet.build_card_for_command('♥5'), HandSet.build_card_for_command('♥6')
                    ])
      end

      def royal_flush
        create_hand([
                      HandSet.build_card_for_command('♥A'), HandSet.build_card_for_command('♥K'), HandSet.build_card_for_command('♥Q'), HandSet.build_card_for_command('♥J'), HandSet.build_card_for_command('♥10')
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
