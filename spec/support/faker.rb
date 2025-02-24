module Faker
  module Card
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
        card = ::Card.new(card_str)
        card.valid? ? card : valid_card
      end

      def invalid_card
        ::Card.new("@1")  # 明らかに不正なカード
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
end 