require 'rails_helper'

RSpec.describe History, type: :model do
  describe 'バリデーション' do
    subject { described_class.new(hand_set: hand_set, rank: rank, ended_at: ended_at) }

    let(:hand_set) { ['♠A', '♥K', '♦Q', '♣J', '♠10'] }
    let(:rank) { 1 }
    let(:ended_at) { Time.current }

    context '正常な値の場合' do
      it { should be_valid }
    end

    context 'hand_setがnilの場合' do
      let(:hand_set) { nil }
      it { should be_invalid }
    end

    context 'rankがnilの場合' do
      let(:rank) { nil }
      it { should be_invalid }
    end

    context 'ended_atがnilの場合' do
      let(:ended_at) { nil }
      it { should be_invalid }
    end

    context 'ended_atが未来日時の場合' do
      let(:ended_at) { 1.day.from_now }
      it { should be_invalid }
      it 'エラーメッセージが含まれること' do
        subject.valid?
        expect(subject.errors[:ended_at]).to include('は未来の日時にできません')
      end
    end
  end
end
