# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HandSet do
  describe '.build' do
    subject { described_class.build(cards) }

    context '正常な手札の場合' do
      let(:cards) { 5.times.map { Faker.valid_card } }

      it '有効なHandSetインスタンスを生成すること' do
        hand_set = subject
        expect(hand_set).to be_a(HandSet)
        expect(hand_set).to be_valid
      end
    end

    context '不正な手札の場合' do
      context 'カードが5枚ではない場合' do
        let(:cards) { 4.times.map { Faker.valid_card } }

        it 'ArgumentErrorが発生すること' do
          expect { subject }.to raise_error(ArgumentError, 'Invalid hand')
        end
      end

      context '不正なカードが含まれる場合' do
        let(:cards) do
          valid_cards = 4.times.map { Faker.valid_card }
          valid_cards + [ Card.new('@1') ]
        end

        it 'ArgumentErrorが発生すること' do
          expect { subject }.to raise_error(ArgumentError, 'Invalid hand')
        end
      end
    end
  end

  describe '#evaluate' do
    subject { hand_set.evaluate }
    let(:hand_set) { Faker.hand_from_cards(cards) }

    context '不正な手札の場合' do
      let(:cards) { 4.times.map { Faker.valid_card } }
      it 'raises ArgumentError' do
        expect { subject }.to raise_error(ArgumentError, '手札が不正です')
      end
    end

    describe '役の評価' do
      context 'ストレートフラッシュの場合' do
        let(:hand_set) { Faker.straight_flush_hand }
        it { should eq HandSet::Rank::STRAIGHT_FLUSH }
      end

      context 'フォーカードの場合' do
        let(:hand_set) { Faker.four_of_a_kind_hand }
        it { should eq HandSet::Rank::FOUR_OF_A_KIND }
      end

      context 'フルハウスの場合' do
        let(:hand_set) { Faker.full_house_hand }
        it { should eq HandSet::Rank::FULL_HOUSE }
      end

      context 'フラッシュの場合' do
        let(:hand_set) { Faker.flush_hand }
        it { should eq HandSet::Rank::FLUSH }
      end

      context 'ストレートの場合' do
        let(:hand_set) { Faker.straight_hand }
        it { should eq HandSet::Rank::STRAIGHT }
      end

      context 'スリーカードの場合' do
        let(:hand_set) { Faker.three_of_a_kind_hand }
        it { should eq HandSet::Rank::THREE_OF_A_KIND }
      end

      context 'ツーペアの場合' do
        let(:hand_set) { Faker.two_pair_hand }
        it { should eq HandSet::Rank::TWO_PAIR }
      end

      context 'ワンペアの場合' do
        let(:hand_set) { Faker.one_pair_hand }
        it { should eq HandSet::Rank::ONE_PAIR }
      end

      context 'ハイカードの場合' do
        let(:hand_set) { Faker.high_card_hand }
        it { should eq HandSet::Rank::HIGH_CARD }
      end
    end
  end

  describe '#rank_name' do
    subject { hand_set.rank_name }
    let(:hand_set) { HandSet.build(cards) }

    context 'ハイカードの場合' do
      let(:cards) { [
        Card.new('♠A'), Card.new('♥K'), Card.new('♦3'), Card.new('♣5'), Card.new('♠7')
      ] }
      it { should eq('ハイカード') }
    end
  end
end
