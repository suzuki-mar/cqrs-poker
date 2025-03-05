# typed: true

require 'rails_helper'

# イベント購読のスパイクテスト
RSpec.describe "EventSubscriptionSpike", type: :spike do
  # シンプルなイベント
  class CardExchangedEvent
    # @!sig attr_reader game_id: String
    # @!sig attr_reader player_id: String
    attr_reader :game_id, :player_id

    # @!sig initialize: (game_id: String, player_id: String) -> void
    def initialize(game_id:, player_id:)
      @game_id = game_id
      @player_id = player_id
    end

    # @!sig to_h: -> Hash[Symbol, String]
    def to_h
      {
        game_id: @game_id,
        player_id: @player_id
      }
    end

    # イベント発行時のメッセージ
    def publish
      Rails.logger.info "メッセージ送信されました: game_id=#{@game_id}, player_id=#{@player_id}"
    end
  end

  # イベント仲介者
  class EventBroker
    # @!sig relay: (Hash[Symbol, String]) -> void
    def relay(payload)
      Rails.logger.info "メッセージを仲介しました: game_id=#{payload[:game_id]}, player_id=#{payload[:player_id]}"
    end
  end

  # シンプルなイベント購読者
  class EventSubscriber
    # @!sig attr_reader received_events: Array[Hash[Symbol, String]]
    attr_reader :received_events

    # @!sig initialize: -> void
    def initialize
      @received_events = []
    end

    # @!sig handle: (Hash[Symbol, String]) -> void
    def handle(event)
      @received_events << event
      Rails.logger.info "メッセージを受信しました: game_id=#{event[:game_id]}, player_id=#{event[:player_id]}"
    end
  end

  it "イベントを発行して購読する" do
    # 購読者と仲介者を作成
    subscriber = EventSubscriber.new
    broker = EventBroker.new

    # イベント購読を設定
    subscription = ActiveSupport::Notifications.subscribe("card_exchanged_event") do |_name, _start, _finish, _id, payload|
      broker.relay(payload)
      subscriber.handle(payload)
    end

    event = CardExchangedEvent.new(game_id: "game-123", player_id: "player-456")
    event.publish
    ActiveSupport::Notifications.instrument("card_exchanged_event", event.to_h)

    # 購読者がイベントを受信したことを確認
    expect(subscriber.received_events.size).to eq(1)
    expect(subscriber.received_events.first[:game_id]).to eq("game-123")
    expect(subscriber.received_events.first[:player_id]).to eq("player-456")

    # クリーンアップ
    ActiveSupport::Notifications.unsubscribe(subscription)
  end
end
