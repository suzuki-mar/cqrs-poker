require 'rails_helper'

RSpec.describe Events::Type do
  describe '::GAME_STARTED' do
    it 'game_startedという文字列であること' do
      expect(described_class::GAME_STARTED).to eq('game_started')
    end
  end

  describe '::ALL' do
    it '全てのイベントタイプを含むこと' do
      expect(described_class::ALL).to include(described_class::GAME_STARTED)
    end

    it '変更不可能であること' do
      expect(described_class::ALL).to be_frozen
    end
  end
end
