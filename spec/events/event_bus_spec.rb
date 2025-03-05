require 'rails_helper'

RSpec.describe EventBus do
  describe '#notify_when_action_completed' do
    let(:event_bus) { EventBus.instance }
    let(:action) { 'test_action' }

    it 'ActiveSupport::Notificationsを使用してイベントを発行すること' do
      expect(ActiveSupport::Notifications).to receive(:instrument).with('action_completed', action: action)
      event_bus.notify_when_action_completed(action)
    end
  end
end
