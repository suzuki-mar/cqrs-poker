require 'rails_helper'

RSpec.describe 'WisperSpike' do
  # 基本的なパブリッシャー
  class Publisher
    include Wisper::Publisher

    def execute(message)
      broadcast(:message_created, message)
      broadcast(:notification_needed, message)
    end
  end

  # リスナー
  class Listener
    def message_created(message)
      @received_message = message
    end

    def notification_needed(message)
      @notification = "通知: #{message}"
    end

    attr_reader :received_message, :notification
  end

  describe '基本的な使い方' do
    let(:publisher) { Publisher.new }
    let(:listener) { Listener.new }

    before do
      publisher.subscribe(listener)
    end

    it 'イベントを発行して購読できること' do
      message = 'テストメッセージ'
      publisher.execute(message)

      expect(listener.received_message).to eq(message)
      expect(listener.notification).to eq("通知: #{message}")
    end
  end

  describe 'イベントの購読方法' do
    let(:publisher) { Publisher.new }
    let(:listener) { Listener.new }

    it '特定のイベントだけを購読できること' do
      # message_createdイベントだけを購読
      publisher.subscribe(listener, on: :message_created)

      message = 'テストメッセージ'
      publisher.execute(message)

      expect(listener.received_message).to eq(message)
      expect(listener.notification).to be_nil
    end
  end

  describe 'グローバルな購読' do
    let(:publisher) { Publisher.new }
    let(:global_listener) { Listener.new }

    before do
      Wisper.clear
    end

    after do
      Wisper.clear
    end

    it 'グローバルにイベントを購読できること' do
      Wisper.subscribe(global_listener)

      message = 'グローバルメッセージ'
      publisher.execute(message)

      expect(global_listener.received_message).to eq(message)
    end
  end
end
