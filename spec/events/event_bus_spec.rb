# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventBus do
  describe '#publish' do
    # テスト用のEventListenerクラス
    class TestEventListener
      attr_reader :received_events

      def initialize
        @received_events = []
      end

      def handle_event(event)
        @received_events << event
      end
    end

    let(:event_publisher) { EventPublisher.new }
    let(:event_listener) { TestEventListener.new }
    let(:event_bus) { EventBus.new(event_publisher: event_publisher, event_listener: event_listener) }

    # テスト用のイベントクラス
    class TestEvent
      def self.name
        'TestEvent'
      end
    end

    it 'イベントがリスナーに届くこと' do
      event = TestEvent.new

      # イベントを発行
      event_bus.publish(event)

      # イベントが正しく届いたことを確認
      expect(event_listener.received_events).to include(event)
    end
  end
end
