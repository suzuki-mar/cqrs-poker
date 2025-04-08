require 'rails_helper'

RSpec.describe GameStartCommand do
  describe '#execute' do
    let(:event_store_domain) { EventStoreDomain.new }
    let(:command) { described_class.new(event_store_domain: event_store_domain) }

    it 'ゲーム開始イベントを作成して返すこと' do
      result = command.execute
      expect(result).to be_a(GameStartedEvent)
    end

    it 'イベントストアにイベントを保存すること' do
      expect {
        command.execute
      }.to change(EventStore, :count).by(1)
    end
  end
end
