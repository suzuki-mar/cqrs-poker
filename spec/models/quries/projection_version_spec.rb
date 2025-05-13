require 'rails_helper'

RSpec.describe Query::ProjectionVersion, type: :model do
  describe 'バリデーション' do
    subject { build(:projection_version) }

    it { should validate_presence_of(:event_id) }
    it { should validate_numericality_of(:event_id).only_integer.is_greater_than_or_equal_to(1) }
    it { should validate_presence_of(:projection_name) }

    describe 'projection_name' do
      context '正常系' do
        it '許可された値でvalidになる' do
          expect(build(:projection_version,
                       projection_name: Query::ProjectionVersion.projection_names[:player_hand_state])).to be_valid
        end
      end
      context '異常系' do
        it '許可されていない値の場合ArgumentErrorが発生する' do
          expect do
            build(:projection_version, projection_name: 'invalid_projection')
          end.to raise_error(ArgumentError)
        end
      end
    end
  end
end
