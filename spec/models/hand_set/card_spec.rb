require 'rails_helper'

RSpec.describe HandSet::Card do
  describe '#valid?' do
    subject { described_class.new(card_str).valid? }

    context '正常な値の場合' do
      context 'スートとランクが正しい場合' do
        context '数字の場合' do
          let!(:card) { CustomFaker.card_with_number(CustomFaker.number_rank) }
          it { expect(card.valid?).to be true }
        end

        context '絵札の場合' do
          let!(:card) { CustomFaker.card_with_number(CustomFaker.face_number) }
          it { expect(card.valid?).to be true }
        end
      end
    end

    context '不正な値の場合' do
      let!(:card) { CustomFaker.invalid_card }
      it { expect(card.valid?).to be false }
    end
  end

  describe '#==' do
    it '同じスート・ランクなら等しい' do
      expect(described_class.new('♠A')).to eq(described_class.new('♠A'))
    end

    it 'スートが違えば等しくない' do
      expect(described_class.new('♠A')).not_to eq(described_class.new('♥A'))
    end

    it 'ランクが違えば等しくない' do
      expect(described_class.new('♠A')).not_to eq(described_class.new('♠2'))
    end

    it '配列のinclude?で正しく判定できる' do
      hand = [described_class.new('♠A'), described_class.new('♥2')]
      expect(hand).to include(described_class.new('♠A'))
      expect(hand).not_to include(described_class.new('♣3'))
    end
  end
end
