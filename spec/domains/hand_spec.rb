require 'rails_helper'

RSpec.describe Hand::Hand do
  describe '#valid?' do
    subject { hand.valid? }
    let(:hand) { described_class.new(cards) }

    context '正常な手札の場合' do
      let(:cards) { 5.times.map { Faker.valid_card } }
      it { should be true }
    end

    context '不正な手札の場合' do
      context 'カードが5枚ではない場合' do
        let(:cards) { 4.times.map { Faker.valid_card } }
        it { should be false }
      end

      context '不正なカードが含まれる場合' do
        let(:cards) do
          valid_cards = 4.times.map { Faker.valid_card }
          valid_cards + [Card.new('@1')]
        end
        it { should be false }
      end

      context '配列ではない場合' do
        let(:cards) { 'not an array' }
        it { should be false }
      end
    end
  end

  describe '#evaluate' do
    subject { hand.evaluate }
    let(:hand) { described_class.new(cards) }

    context '不正な手札の場合' do
      let(:cards) { 4.times.map { Faker.valid_card } }
      it 'raises ArgumentError' do
        expect { subject }.to raise_error(ArgumentError, '手札が不正です')
      end
    end

    describe '役の評価' do
      context 'ストレートフラッシュの場合' do
        let(:hand) { Faker.straight_flush_hand }
        it { should eq Hand::Rank::STRAIGHT_FLUSH }
      end

      context 'フォーカードの場合' do
        let(:hand) { Faker.four_of_a_kind_hand }
        it { should eq Hand::Rank::FOUR_OF_A_KIND }
      end

      context 'フルハウスの場合' do
        let(:hand) { Faker.full_house_hand }
        it { should eq Hand::Rank::FULL_HOUSE }
      end

      context 'フラッシュの場合' do
        let(:hand) { Faker.flush_hand }
        it { should eq Hand::Rank::FLUSH }
      end

      context 'ストレートの場合' do
        let(:hand) { Faker.straight_hand }
        it { should eq Hand::Rank::STRAIGHT }
      end

      context 'スリーカードの場合' do
        let(:hand) { Faker.three_of_a_kind_hand }
        it { should eq Hand::Rank::THREE_OF_A_KIND }
      end

      context 'ツーペアの場合' do
        let(:hand) { Faker.two_pair_hand }
        it { should eq Hand::Rank::TWO_PAIR }
      end

      context 'ワンペアの場合' do
        let(:hand) { Faker.one_pair_hand }
        it { should eq Hand::Rank::ONE_PAIR }
      end

      context 'ハイカードの場合' do
        let(:hand) { Faker.high_card_hand }
        it { should eq Hand::Rank::HIGH_CARD }
      end
    end
  end
end 