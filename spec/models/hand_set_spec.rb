require 'rails_helper'

RSpec.describe HandSet do
  let(:cards) { Array.new(5) { instance_double(HandSet::Card, valid?: true) } }
  let(:hand_set) { described_class.build(cards) }

  describe '.build' do
    it '有効なカード配列からHandSetを生成できる' do
      expect(hand_set).to be_a(HandSet)
    end

    it '不正なカード配列の場合は例外を投げる' do
      expect { described_class.build([1, 2, 3]) }.to raise_error(ArgumentError)
    end
  end

  describe '#evaluate' do
    it 'HandSet::RankEvaluater.callが呼ばれる' do
      allow(HandSet::RankEvaluater).to receive(:call).and_return(:high_card)
      expect(hand_set.evaluate).to eq(:high_card)
    end

    HandSet::Rank.constants.each do |rank_const|
      next if %i[ALL NAMES].include?(rank_const) # 補助定数は除外

      it "#{rank_const} が返る場合のテスト" do
        rank_value = HandSet::Rank.const_get(rank_const)
        allow(HandSet::RankEvaluater).to receive(:call).and_return(rank_value)
        expect(hand_set.evaluate).to eq(rank_value)
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
