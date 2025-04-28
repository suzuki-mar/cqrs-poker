require 'rails_helper'

RSpec.describe PlayerHandState, type: :model do
  describe 'バリデーション' do
    describe '手札 hand_set' do
      subject { build(:player_hand_state, hand_set: hand_set_value) }

      context '正常な値の場合' do
        let(:hand_set_value) { Array.new(5) { Faker::Card.valid_card.to_s } }
        it { should be_valid }
      end

      context '5枚未満の場合' do
        let(:hand_set_value) { Array.new(4) { Faker::Card.valid_card.to_s } }
        it { should be_invalid }
      end

      context '5枚より多い場合' do
        let(:hand_set_value) { Array.new(6) { Faker::Card.valid_card.to_s } }
        it { should be_invalid }
      end

      context '空配列の場合' do
        let(:hand_set_value) { [] }
        it { should be_invalid }
      end

      context 'nilを含む場合' do
        let(:hand_set_value) { [nil, *Array.new(4) { Faker::Card.valid_card.to_s }] }
        it { should be_invalid }
      end

      context '文字列以外を含む場合' do
        let(:hand_set_value) { [1, 2, 3, 4, 5] }
        it { should be_invalid }
      end
    end

    describe 'current_rank' do
      it { should validate_presence_of(:current_rank) }
      it { should validate_inclusion_of(:current_rank).in_array(ReadModels::HandSet::Rank::ALL) }

      describe '不正な値' do
        subject { build(:player_hand_state, current_rank: invalid_value) }

        context '存在しない役の場合' do
          let(:invalid_value) { 'INVALID_HAND' }
          it { should be_invalid }
        end
      end
    end

    describe 'current_turn' do
      it { should validate_presence_of(:current_turn) }
      it {
        should validate_numericality_of(:current_turn)
          .only_integer
          .is_greater_than_or_equal_to(1)
          .is_less_than_or_equal_to(100)
      }

      describe '不正な値' do
        subject { build(:player_hand_state, current_turn: invalid_value) }

        context '0以下の値の場合' do
          let(:invalid_value) { 0 }
          it { should be_invalid }
        end

        context '小数の場合' do
          let(:invalid_value) { 1.5 }
          it { should be_invalid }
        end

        context '上限値を超える場合' do
          let(:invalid_value) { 1000 }
          it { should be_invalid }
        end
      end
    end
  end
end
