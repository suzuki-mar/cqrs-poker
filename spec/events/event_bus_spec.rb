require 'rails_helper'

RSpec.describe EventBus do
  describe '#notify_when_action_completed' do
    let(:event_bus) { EventBus.instance }
    let(:action) { 'test_action' }

    it 'ActiveSupport::Notificationsを使用してイベントを発行すること' do
      expect(ActiveSupport::Notifications).to receive(:instrument).with('action_completed', action: action)
      event_bus.notify_when_action_completed(action)
    end

    context 'リスナーが登録されている場合' do
      it 'リスナーを呼び出すこと' do
        listener = double('listener')
        expect(listener).to receive(:call).with(action)

        event_bus.register_action_completed_listener(listener)
        event_bus.notify_when_action_completed(action)
      end
    end
  end

  describe '#register_action_completed_listener' do
    let(:event_bus) { EventBus.instance }
    let(:listener) { double('listener') }

    before do
      # テスト間で状態が共有されないようにリセット
      event_bus.instance_variable_set(:@action_completed_listener, nil)
      event_bus.instance_variable_set(:@subscription, nil)
    end

    it 'リスナーを登録すること' do
      expect(ActiveSupport::Notifications).to receive(:subscribe).with('action_completed')
      event_bus.register_action_completed_listener(listener)
      expect(event_bus.instance_variable_get(:@action_completed_listener)).to eq(listener)
    end

    context '既にリスナーが登録されている場合' do
      it '新しいリスナーを登録しないこと' do
        first_listener = double('first_listener')
        event_bus.register_action_completed_listener(first_listener)

        event_bus.register_action_completed_listener(listener)
        expect(event_bus.instance_variable_get(:@action_completed_listener)).to eq(first_listener)
      end
    end
  end
end
