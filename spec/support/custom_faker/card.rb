module CustomFaker
  module Card
    @used_cards = Set.new

    class << self
      def suit
        ::HandSet::Card::VALID_SUITS.sample
      end

      def number
        ::HandSet::Card::VALID_NUMBERS.sample
      end

      def number_rank
        ::HandSet::Card::VALID_NUMBERS.grep(/\d+/).sample
      end

      def face_number
        (::HandSet::Card::VALID_NUMBERS - ::HandSet::Card::VALID_NUMBERS.grep(/\d+/)).sample
      end

      def valid_card
        HandSet.build_card(unique_card_str)
      end

      def invalid_card
        HandSet.build_card('@1')
      end

      def card_with_suit(suit_value)
        HandSet.build_card("#{suit_value}#{number}")
      end

      def card_with_number(number_value)
        HandSet.build_card("#{suit}#{number_value}")
      end

      def reset_unique_cards
        @used_cards.clear
      end

      private

      def card_str
        "#{suit}#{number}"
      end

      def unique_card_str
        loop do
          card = card_str
          unless @used_cards.include?(card)
            @used_cards.add(card)
            return card
          end
        end
      end
    end
  end
end
