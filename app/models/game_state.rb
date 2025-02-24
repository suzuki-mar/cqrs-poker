class GameState < ApplicationRecord
  VALID_RANKS = ['HIGH_CARD', 'ONE_PAIR', 'TWO_PAIR', 'THREE_OF_A_KIND',
                 'STRAIGHT', 'FLUSH', 'FULL_HOUSE', 'FOUR_OF_A_KIND',
                 'STRAIGHT_FLUSH', 'ROYAL_FLUSH'].freeze

  validates :hand_1, presence: true, format: { 
    with: /\A[#{Card::VALID_SUITS.join}][#{Card::VALID_RANKS.join}|10]\z/,
    message: '不正なカード形式です' 
  }
  validates :hand_2, presence: true
  validates :hand_3, presence: true
  validates :hand_4, presence: true
  validates :hand_5, presence: true
  validates :current_rank, presence: true, inclusion: { in: VALID_RANKS }
  
  validates :current_turn, presence: true, 
                          numericality: { 
                            only_integer: true,
                            greater_than_or_equal_to: 1,
                            less_than_or_equal_to: 100  # 十分な余裕を持った上限値
                          }

  private

  def valid_card?(card)
    return false unless card.match?(/\A[♠♥♦♣][A2-9]|10|[JQK]\z/)
    suit = card[0]
    rank = card[1..-1]
    valid_suit?(suit) && valid_rank?(rank)
  end

  def valid_suit?(suit)
    %w[♠ ♥ ♦ ♣].include?(suit)
  end

  def valid_rank?(rank)
    valid_ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K']
    valid_ranks.include?(rank)
  end
end
