require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'バリデーション' do
    describe 'event_type' do
      it { should validate_presence_of(:event_type) }
    end

    describe 'event_data' do
      it { should validate_presence_of(:event_data) }

      it '不正なJSONの場合はエラーがおきること' do
        event = build_stubbed(:event, event_data: 'invalid_json')
        expect(event).not_to be_valid
        expect(event.errors[:event_data]).to include('must be valid JSON')
      end
    end

    describe 'occurred_at' do
      it { should validate_presence_of(:occurred_at) }

      it '未来の日付の場合はエラーがおきること' do
        event = build_stubbed(:event, occurred_at: 1.second.from_now)
        expect(event).not_to be_valid
      end
    end

    describe 'version' do
      it { should validate_presence_of(:version) }
      it {
        create(:event, version: 1, game_number: 100)
        should validate_uniqueness_of(:version).scoped_to(:game_number)
      }

      it '同じgame_number内で重複したversionの場合は無効であること' do
        create(:event, version: 1, game_number: 100)
        event = build(:event, version: 1, game_number: 100)
        expect(event).not_to be_valid
        expect(event.errors[:version]).to include('has already been taken')
      end

      it '異なるgame_numberなら同じversionでも有効であること' do
        create(:event, version: 1, game_number: 100)
        event = build(:event, version: 1, game_number: 200)
        expect(event).to be_valid
      end
    end

    describe 'game_number' do
      it_behaves_like 'game_number column examples'
    end
  end
end
