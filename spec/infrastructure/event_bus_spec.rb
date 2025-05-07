# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventBus do
  describe '#publish' do
    let(:event_listener) { TestEventListener.new }
    let(:projection) { Projection.new }
    let(:event_publisher) { EventPublisher.new(projection: projection, event_listener: event_listener) }
    let(:event_bus) { EventBus.new(event_publisher) }
    let(:board) { Aggregates::BoardAggregate.new }
    let(:initial_hand) { board.draw_initial_hand }
    let(:event) { GameStartedEvent.new(initial_hand) }

    it 'イベントがリスナーに届くこと' do
      # イベントを発行
      event_bus.publish(event)

      # イベントが正しく届いたことを確認
      expect(event_listener.received_events).to include(event)
    end
  end
end
