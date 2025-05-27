module CustomFaker
  module Hand
    class << self
      def high_card_hand
        create_hand([
                      HandSet.build_card('♠A'),
                      HandSet.build_card('♥K'),
                      HandSet.build_card('♦3'),
                      HandSet.build_card('♣5'),
                      HandSet.build_card('♠7')
                    ])
      end

      def one_pair_hand
        create_hand([
                      HandSet.build_card('♠A'),
                      HandSet.build_card('♥A'),
                      HandSet.build_card('♦3'),
                      HandSet.build_card('♣5'),
                      HandSet.build_card('♠7')
                    ])
      end

      def two_pair_hand
        create_hand([
                      HandSet.build_card('♠A'),
                      HandSet.build_card('♥A'),
                      HandSet.build_card('♦K'),
                      HandSet.build_card('♣K'),
                      HandSet.build_card('♠7')
                    ])
      end

      def three_of_a_kind_hand
        create_hand([
                      HandSet.build_card('♥7'),
                      HandSet.build_card('♦7'),
                      HandSet.build_card('♣7'),
                      HandSet.build_card('♠3'),
                      HandSet.build_card('♥5')
                    ])
      end

      def straight_hand
        create_hand([
                      HandSet.build_card('♥2'),
                      HandSet.build_card('♦3'),
                      HandSet.build_card('♣4'),
                      HandSet.build_card('♠5'),
                      HandSet.build_card('♥6')
                    ])
      end

      def flush_hand
        create_hand([
                      HandSet.build_card('♥2'),
                      HandSet.build_card('♥5'),
                      HandSet.build_card('♥7'),
                      HandSet.build_card('♥9'),
                      HandSet.build_card('♥J')
                    ])
      end

      def full_house_hand
        create_hand([
                      HandSet.build_card('♥8'),
                      HandSet.build_card('♦8'),
                      HandSet.build_card('♣8'),
                      HandSet.build_card('♠4'),
                      HandSet.build_card('♥4')
                    ])
      end

      def four_of_a_kind_hand
        create_hand([
                      HandSet.build_card('♥7'),
                      HandSet.build_card('♦7'),
                      HandSet.build_card('♣7'),
                      HandSet.build_card('♠7'),
                      HandSet.build_card('♥2')
                    ])
      end

      def straight_flush_hand
        create_hand([
                      HandSet.build_card('♥2'),
                      HandSet.build_card('♥3'),
                      HandSet.build_card('♥4'),
                      HandSet.build_card('♥5'),
                      HandSet.build_card('♥6')
                    ])
      end

      def royal_flush_hand
        create_hand([
                      HandSet.build_card('♥A'),
                      HandSet.build_card('♥K'),
                      HandSet.build_card('♥Q'),
                      HandSet.build_card('♥J'),
                      HandSet.build_card('♥10')
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
