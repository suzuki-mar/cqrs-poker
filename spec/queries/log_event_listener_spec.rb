# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LogEventListener do
  let(:logger) { TestLogger.new }
  let(:listener) { described_class.new(logger) }
  let(:board) { Aggregates::BoardAggregate.new }
  let(:initial_hand) { board.draw_initial_hand }

  describe '#handle_event' do
    it 'GameStartedEventのログ出力' do
      event = SuccessEvents::GameStarted.new(initial_hand)
      listener.handle_event(event)
      expect(logger.messages_for_level(:info).last).to match(/ゲーム開始/)
    end

    it '未知のイベントも受信してログ出力できること' do
      unknown_event = double('UnknownEvent', class: double(name: 'UnknownEvent'))
      listener.handle_event(unknown_event)
      expect(logger.messages_for_level(:info)).to include(/イベント受信:/)
    end

    it 'InvalidCommandEventのwarnログ出力' do
      event = CommandErrors::InvalidCommand.new(command: 'Command', reason: '手札に存在しないカードです')
      listener.handle_event(event)
      expect(logger.messages_for_level(:warn).last).to match(/不正な選択肢の選択/)
      expect(logger.messages_for_level(:warn).last).to include('手札に存在しないカードです')
    end
  end
end
