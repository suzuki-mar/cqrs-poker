require 'rails_helper'

RSpec.describe Query::Trash, type: :model do
  describe 'バリデーション' do
    describe 'discarded_cards' do
      subject { build_stubbed(:trash, discarded_cards: discarded_cards_value, last_event_id: 1) }

      context '正常な値の場合' do
        let(:discarded_cards_value) { Array.new(2) { Faker::Card.valid_card.to_s } }
        it { should be_valid }
      end

      context '空配列の場合' do
        let(:discarded_cards_value) { [] }
        it { should be_invalid }
      end

      context 'nilの場合' do
        let(:discarded_cards_value) { nil }
        it { should be_invalid }
      end

      context '配列でない場合' do
        let(:discarded_cards_value) { 'not an array' }
        it { should be_invalid }
      end

      context '配列内にnilを含む場合' do
        let(:discarded_cards_value) { [nil, Faker::Card.valid_card.to_s] }
        it { should be_valid }
      end
    end

    describe 'current_turn' do
      it { should validate_presence_of(:current_turn) }

      describe '不正な値' do
        subject { build(:trash, current_turn: invalid_value) }

        context '0以下の値の場合' do
          let(:invalid_value) { 0 }
          it { should be_invalid }
        end

        context '上限値を超える場合' do
          let(:invalid_value) { 1000 }
          it { should be_invalid }
        end
      end
    end
  end

  describe 'last_event_id' do
    it 'last_event_idを設定・取得できること' do
      trash = build(:trash, last_event_id: 99)
      expect(trash.last_event_id).to eq 99
    end
  end
end
