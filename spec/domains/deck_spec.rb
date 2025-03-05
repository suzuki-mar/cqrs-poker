require 'rails_helper'

RSpec.describe Deck do
  # 各テストの前にデッキをリセット
  before(:each) do
    Deck.instance.reset
  end

  describe '#initialize' do
    it '52枚のカードを持つデッキが生成されること' do
      deck = Deck.instance
      expect(deck.size).to eq(52)
    end
    
    it '全てのカードが一意であること' do
      deck = Deck.instance
      cards = deck.draw(52)
      card_strings = cards.map(&:to_s)
      expect(card_strings.uniq.size).to eq(52)
    end
  end
  
  describe '#draw' do
    let(:deck) { Deck.instance }
    
    it '指定した枚数のカードを引くこと' do
      cards = deck.draw(5)
      expect(cards.size).to eq(5)
      expect(deck.size).to eq(47)
    end
    
    context 'デッキの残りより多く引こうとした場合' do
      it '残っているカードだけを引くこと' do
        deck.draw(50) # 残り2枚
        cards = deck.draw(5)
        expect(cards.size).to eq(2)
        expect(deck.size).to eq(0)
      end
    end
  end
  
  describe '#size' do
    it 'デッキに残っているカードの枚数を返すこと' do
      deck = Deck.instance
      expect(deck.size).to eq(52)
      deck.draw(10)
      expect(deck.size).to eq(42)
    end
  end
  
  describe '#reset' do
    it 'デッキをリセットすること' do
      deck = Deck.instance
      deck.draw(10) # 残り42枚
      deck.reset
      expect(deck.size).to eq(52)
    end
  end
  
  describe '#remaining_cards' do
    it 'スートごとにグループ化されたカードのハッシュを返すこと' do
      deck = Deck.instance
      deck.reset
      
      remaining = deck.remaining_cards
      expect(remaining.keys).to contain_exactly('♠', '♥', '♦', '♣')
      expect(remaining['♠'].size).to eq(13) # スペードは13枚
      expect(remaining['♥'].size).to eq(13) # ハートは13枚
      expect(remaining['♦'].size).to eq(13) # ダイヤは13枚
      expect(remaining['♣'].size).to eq(13) # クラブは13枚
      
      # カードを引いた後
      deck.draw(5)
      remaining = deck.remaining_cards
      expect(remaining.values.flatten.size).to eq(47)
    end
  end

  describe '#find_by_suit' do
    it '特定のスートのカードを返すこと' do
      deck = Deck.instance
      deck.reset
      
      hearts = deck.find_by_suit('♥')
      expect(hearts.size).to eq(13) # ハートは13枚
      expect(hearts).to all(satisfy { |card| card.to_s.start_with?('♥') })
    end
  end

  describe '#find_by_rank' do
    it '特定のランクのカードを返すこと' do
      deck = Deck.instance
      deck.reset
      
      aces = deck.find_by_rank('A')
      expect(aces.size).to eq(4) # エースは4枚
      expect(aces).to all(satisfy { |card| card.to_s.end_with?('A') })
    end
  end
end 