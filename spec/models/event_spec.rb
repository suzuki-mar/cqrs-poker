require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'バリデーション' do
    describe 'event_type' do
      it { should validate_presence_of(:event_type) }
    end

    describe 'event_data' do
      it { should validate_presence_of(:event_data) }

      it '不正なJSONの場合はエラーがおきること' do
        event = build(:event, event_data: 'invalid_json')
        expect(event).not_to be_valid
        expect(event.errors[:event_data]).to include("must be valid JSON")
      end
    end

    describe 'occurred_at' do
      it { should validate_presence_of(:occurred_at) }

      it '未来の日付の場合はエラーがおきること' do
        event = build(:event, occurred_at: 1.second.from_now)
        expect(event).not_to be_valid
      end
    end

    describe 'version' do
      it { should validate_presence_of(:version) }
      it {
        create(:event, version: 1)
        should validate_uniqueness_of(:version).case_insensitive
      }

      it '重複したversionの場合は無効であること' do
        create(:event, version: 1)
        event = build(:event, version: 1)
        expect(event).not_to be_valid
        expect(event.errors[:version]).to include('has already been taken')
      end
    end
  end
end
