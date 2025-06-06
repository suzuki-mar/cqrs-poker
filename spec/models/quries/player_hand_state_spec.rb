require 'rails_helper'

RSpec.describe Query::PlayerHandState, type: :model do
  describe 'バリデーション' do
    describe '手札 hand_set' do
      subject { build_stubbed(:player_hand_state, hand_set: hand_set_value, last_event_id: 1) }

      context '正常な値の場合' do
        let!(:hand_set_value) { Array.new(5) { CustomFaker.valid_card.to_s } }
        it { should be_valid }
      end

      context '5枚未満の場合' do
        let!(:hand_set_value) { Array.new(4) { CustomFaker.valid_card.to_s } }
        it { should be_invalid }
      end

      context '5枚より多い場合' do
        let!(:hand_set_value) { Array.new(6) { CustomFaker.valid_card.to_s } }
        it { should be_invalid }
      end

      context '空配列の場合' do
        let!(:hand_set_value) { [] }
        it { should be_invalid }
      end

      context 'nilを含む場合' do
        let!(:hand_set_value) { [nil, *Array.new(4) { CustomFaker.valid_card.to_s }] }
        it { should be_invalid }
      end

      context '文字列以外を含む場合' do
        let!(:hand_set_value) { [1, 2, 3, 4, 5] }
        it { should be_invalid }
      end
    end

    describe 'current_rank' do
      it { should validate_presence_of(:current_rank) }
      it { should validate_inclusion_of(:current_rank).in_array(HandSet::Rank::ALL) }

      describe '不正な値' do
        subject { build_stubbed(:player_hand_state, current_rank: invalid_value, last_event_id: 1) }

        context '存在しない役の場合' do
          let!(:invalid_value) { 'INVALID_HAND' }
          it { should be_invalid }
        end
      end
    end

    describe 'current_turn' do
      it { should validate_presence_of(:current_turn) }

      describe '不正な値' do
        subject { build(:player_hand_state, current_turn: invalid_value) }

        context '0以下の値の場合' do
          let!(:invalid_value) { 0 }
          it { should be_invalid }
        end

        context '上限値を超える場合' do
          let!(:invalid_value) { 1000 }
          it { should be_invalid }
        end
      end
    end
  end

  describe 'last_event_id' do
    it 'last_event_idを設定・取得できること' do
      player_hand_state = build(:player_hand_state, last_event_id: 42)
      expect(player_hand_state.last_event_id).to eq 42
    end
  end

  describe 'game_number' do
    it_behaves_like 'game_number column examples'
  end
end
