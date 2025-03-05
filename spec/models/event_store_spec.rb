require 'rails_helper'

RSpec.describe EventStore, type: :model do
  describe 'バリデーション' do
    describe 'event_type' do
      it { should validate_presence_of(:event_type) }
    end

    describe 'event_data' do
      it { should validate_presence_of(:event_data) }

      it '不正なJSONの場合はエラーがおきること' do
        event_store = build(:event_store, event_data: 'invalid_json')
        expect(event_store).not_to be_valid
        expect(event_store.errors[:event_data]).to include("must be valid JSON")
      end
    end

    describe 'occurred_at' do
      it { should validate_presence_of(:occurred_at) }
      
      it '未来の日付の場合はエラーがおきること' do
        event_store = build(:event_store, occurred_at: 1.second.from_now)
        expect(event_store).not_to be_valid       
      end
      
    end
  end
end 