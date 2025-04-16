# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LogEventListener do
  let(:logger) { TestLogger.new }
  let(:listener) { described_class.new(logger) }

  describe '#handle_event' do
    it 'イベントを受信してログ出力できること' do
      event = GameStartedEvent.new(HandSet.generate_initial)
      listener.handle_event(event)
      expect(logger.messages_for_level(:info)).to include(/イベント受信:/)
    end

    it '未知のイベントも受信してログ出力できること' do
      unknown_event = double('UnknownEvent', class: double(name: 'UnknownEvent'))
      listener.handle_event(unknown_event)
      expect(logger.messages_for_level(:info)).to include(/イベント受信:/)
    end
  end
end
