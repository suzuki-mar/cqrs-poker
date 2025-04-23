require 'rails_helper'

RSpec.describe Card do
  describe '#valid?' do
    subject { Card.new(card_str).valid? }

    context '正常な値の場合' do
      context 'スートとランクが正しい場合' do
        context '数字の場合' do
          let(:card) { Faker::Card.card_with_rank(Faker::Card.number_rank) }
          it { expect(card.valid?).to be true }
        end

        context '絵札の場合' do
          let(:card) { Faker::Card.card_with_rank(Faker::Card.face_rank) }
          it { expect(card.valid?).to be true }
        end
      end
    end

    context '不正な値の場合' do
      let(:card) { Faker::Card.invalid_card }
      it { expect(card.valid?).to be false }
    end
  end

  describe '#==' do
    it '同じスート・ランクなら等しい' do
      expect(Card.new('♠A')).to eq(Card.new('♠A'))
    end

    it 'スートが違えば等しくない' do
      expect(Card.new('♠A')).not_to eq(Card.new('♥A'))
    end

    it 'ランクが違えば等しくない' do
      expect(Card.new('♠A')).not_to eq(Card.new('♠2'))
    end

    it '配列のinclude?で正しく判定できる' do
      hand = [ Card.new('♠A'), Card.new('♥2') ]
      expect(hand).to include(Card.new('♠A'))
      expect(hand).not_to include(Card.new('♣3'))
    end
  end
end
