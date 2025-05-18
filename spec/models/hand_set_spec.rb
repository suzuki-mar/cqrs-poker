require 'rails_helper'
require 'rspec-parameterized'
require 'support/custom_faker'

RSpec.describe HandSet do
  let(:cards) { Array.new(5) { instance_double(HandSet::Card, valid?: true) } }
  let(:hand_set) { described_class.build(cards) }
  let(:excluded_rank_consts) { %i[ALL NAMES] }

  describe '.build' do
    it '有効なカード配列からHandSetを生成できる' do
      expect(hand_set).to be_a(HandSet)
    end

    it '不正なカード配列の場合は例外を投げる' do
      expect { described_class.build([1, 2, 3]) }.to raise_error(ArgumentError)
    end
  end

  describe '#evaluate' do
    where(:faker, :expected_rank, :skip) do
      [
        [-> { CustomFaker.high_card_hand.cards },      HandSet::Rank::HIGH_CARD,      false],
        [-> { CustomFaker.one_pair_hand.cards },       HandSet::Rank::ONE_PAIR,       false],
        [-> { CustomFaker.two_pair_hand.cards },       HandSet::Rank::TWO_PAIR,       false],
        [-> { CustomFaker.three_of_a_kind_hand.cards }, HandSet::Rank::THREE_OF_A_KIND, false],
        [-> { CustomFaker.straight_hand.cards },       HandSet::Rank::STRAIGHT,       false],
        [-> { CustomFaker.flush_hand.cards },          HandSet::Rank::FLUSH,          false],
        [-> { CustomFaker.full_house_hand.cards },     HandSet::Rank::FULL_HOUSE,     false],
        [-> { CustomFaker.four_of_a_kind_hand.cards }, HandSet::Rank::FOUR_OF_A_KIND, false],
        [-> { CustomFaker.straight_flush_hand.cards }, HandSet::Rank::STRAIGHT_FLUSH, false],
        [-> { CustomFaker.royal_flush_hand.cards }, HandSet::Rank::ROYAL_FLUSH, true]
      ]
    end

    with_them do
      it '正しい役が返ること' do
        hand_set = HandSet.build(faker.call)
        expect(hand_set.evaluate).to eq(expected_rank)
      end
    end
  end

  describe '#rank_name' do
    it '役名が取得できる' do
      allow(hand_set).to receive(:evaluate).and_return(:high_card)
      allow(HandSet).to receive(:rank_names).and_return({ high_card: 'ハイカード' })
      expect(hand_set.rank_name).to eq('ハイカード')
    end
  end

  describe '#valid?' do
    it '有効なカード配列ならtrueを返す' do
      expect(hand_set.valid?).to be true
    end

    it '不正なカード配列ならfalseを返す' do
      invalid_hand_set = described_class.build(cards)
      allow(described_class).to receive(:valid_cards?).and_return(false)
      expect(invalid_hand_set.valid?).to be false
    end
  end
end
