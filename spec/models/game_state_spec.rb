require 'rails_helper'

RSpec.describe GameState, type: :model do
  shared_examples '手札のバリデーション' do |hand_number|
    describe "hand_#{hand_number}" do
      let(:card_value) { nil }
      subject { build(:game_state, "hand_#{hand_number}": card_value) }

      it { should validate_presence_of(:"hand_#{hand_number}") }

      context '正常な値の場合' do
        let(:card_value) { Faker::Card.valid_card.to_s }
        it { should be_valid }
      end

      context '不正な値の場合' do
        let(:card_value) { '@1' }
        it { should be_invalid }
      end
    end
  end

  describe 'バリデーション' do
    describe '手札' do
      it_behaves_like '手札のバリデーション', 1
      it_behaves_like '手札のバリデーション', 2
      it_behaves_like '手札のバリデーション', 3
      it_behaves_like '手札のバリデーション', 4
      it_behaves_like '手札のバリデーション', 5
    end

    describe 'current_rank' do
      it { should validate_presence_of(:current_rank) }
      it { should validate_inclusion_of(:current_rank).in_array(Hand::Rank::ALL) }

      describe '不正な値' do
        subject { build(:game_state, current_rank: invalid_value) }

        context '存在しない役の場合' do
          let(:invalid_value) { 'INVALID_HAND' }
          it { should be_invalid }
        end
      end
    end

    describe 'current_turn' do
      it { should validate_presence_of(:current_turn) }
      it { should validate_numericality_of(:current_turn)
             .only_integer
             .is_greater_than_or_equal_to(1)
             .is_less_than_or_equal_to(100) }

      describe '不正な値' do
        subject { build(:game_state, current_turn: invalid_value) }

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