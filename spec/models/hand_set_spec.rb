require 'rails_helper'
require 'rspec-parameterized'

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
        [-> { Faker.high_card_hand.cards },      HandSet::Rank::HIGH_CARD,      false],
        [-> { Faker.one_pair_hand.cards },       HandSet::Rank::ONE_PAIR,       false],
        [-> { Faker.two_pair_hand.cards },       HandSet::Rank::TWO_PAIR,       false],
        [-> { Faker.three_of_a_kind_hand.cards }, HandSet::Rank::THREE_OF_A_KIND, false],
        [-> { Faker.straight_hand.cards },       HandSet::Rank::STRAIGHT,       false],
        [-> { Faker.flush_hand.cards },          HandSet::Rank::FLUSH,          false],
        [-> { Faker.full_house_hand.cards },     HandSet::Rank::FULL_HOUSE,     false],
        [-> { Faker.four_of_a_kind_hand.cards }, HandSet::Rank::FOUR_OF_A_KIND, false],
        [-> { Faker.straight_flush_hand.cards }, HandSet::Rank::STRAIGHT_FLUSH, false],
        [-> { Faker::Hand.royal_flush.cards },   HandSet::Rank::ROYAL_FLUSH,    true]
      ]
    end

    with_them do
      it '正しい役が返ること' do
        if RSpec.configuration.formatters.any? { |f| f.class.name.include?('DocumentationFormatter') }
          puts "テスト対象: expected_rank=#{expected_rank}"
        end
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
