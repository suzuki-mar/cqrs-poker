# このファイルは、テストライブラリやテストツールの動作確認用です。
# 実際のアプリケーションコードのテストではありません。

require 'rails_helper'

RSpec.describe EventStore, type: :model do
  describe 'バリデーション' do
    it { should validate_presence_of(:event_type) }
    it { should validate_presence_of(:occurred_at) }
  end
end 