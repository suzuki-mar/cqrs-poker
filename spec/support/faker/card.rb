module Faker
  class CardGenerator
    class << self
      def suit
        ::Card::VALID_SUITS.sample
      end

      def rank
        ::Card::VALID_RANKS.sample
      end

      def number_rank
        ::Card::VALID_RANKS.grep(/\d+/).sample
      end

      def face_rank
        %w[A J Q K].sample
      end

      def valid_card
        ::Card.new(card_str)
      end

      def invalid_card
        ::Card.new('@1')
      end

      def card_with_suit(suit_value)
        ::Card.new("#{suit_value}#{rank}")
      end

      def card_with_rank(rank_value)
        ::Card.new("#{suit}#{rank_value}")
      end

      private

      def card_str
        "#{suit}#{rank}"
      end
    end
  end

  module Card
    class << self
      def suit
        CardGenerator.suit
      end

      def rank
        CardGenerator.rank
      end

      def number_rank
        CardGenerator.number_rank
      end

      def face_rank
        CardGenerator.face_rank
      end

      def valid_card
        CardGenerator.valid_card
      end

      def invalid_card
        CardGenerator.invalid_card
      end

      def card_with_suit(suit_value)
        CardGenerator.card_with_suit(suit_value)
      end

      def card_with_rank(rank_value)
        CardGenerator.card_with_rank(rank_value)
      end
    end
  end
end 