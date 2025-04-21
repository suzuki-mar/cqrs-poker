require 'rails_helper'

RSpec.describe EventPublisher do
  # このテストに失敗するとboradcastメソッドに通知されない
  describe '購読者インターフェースを実装していること' do
    it 'projectionはhandle_eventメソッドを持つこと' do
      expect(Projection.new).to respond_to(:handle_event)
    end

    it 'event_listenerはhandle_eventメソッドを持つこと' do
      expect(LogEventListener.new(Logger.new(nil))).to respond_to(:handle_event)
    end
  end
end
