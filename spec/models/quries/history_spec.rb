require 'rails_helper'

RSpec.describe Query::History, type: :model do
  describe 'バリデーション' do
    context '正常な値の場合' do
      it { expect(build(:history)).to be_valid }
    end

    context 'hand_setがnilの場合' do
      it { expect(build(:history, hand_set: nil)).to be_invalid }
    end

    context 'rankがnilの場合' do
      it { expect(build(:history, rank: nil)).to be_invalid }
    end

    context 'ended_atがnilの場合' do
      it { expect(build(:history, ended_at: nil)).to be_invalid }
    end

    context 'ended_atが未来日時の場合' do
      it { expect(build(:history, ended_at: 1.day.from_now)).to be_invalid }
      it 'エラーメッセージが含まれること' do
        history = build(:history, ended_at: 1.day.from_now)
        history.valid?
        expect(history.errors[:ended_at]).to include('は未来の日時にできません')
      end
    end
  end

  describe 'last_event_id' do
    it 'last_event_idを設定・取得できること' do
      history = build(:history, last_event_id: 7)
      expect(history.last_event_id).to eq 7
    end
  end

  describe 'game_number' do
    it_behaves_like 'game_number column examples'
  end
end
