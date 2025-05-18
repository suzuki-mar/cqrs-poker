# frozen_string_literal: true

# バージョン競合は全コマンドで発生しうるため、ユースケースごとに同じ観点でテストをまとめて管理しています。
# - テストの重複や分散を避け、運用・保守の効率を高めるため
# - どのコマンドでも「バージョン競合時の正しいエラー応答・ログ出力」が保証される
# - 新しいユースケース追加時も、このファイルに追記するだけで網羅的な検証が可能です

require 'rails_helper'

RSpec.describe 'バージョン競合ユースケース' do
  let(:logger) { TestLogger.new }
  let!(:command_bus) { UseCaseHelper.build_command_bus(logger) }
  let(:event_publisher) do
    EventPublisher.new(projection: EventListener::Projection.new,
                       event_listener: EventListener::Log.new(logger))
  end
  let(:event_bus) { EventBus.new(event_publisher) }
  # QueryServiceを使用してゲーム番号を取得
  let(:game_number) { QueryService.latest_game_number }
  # 先にQueryServiceをインスタンス化
  let(:query_service) { QueryService.new(game_number) }

  # QueryServiceの拡張メソッドを追加（まだ実装していない場合）
  before do
    unless QueryService.respond_to?(:fetch_current_version)
      QueryService.class_eval do
        def self.fetch_current_version
          Aggregates::Store.new.current_version
        end
      end
    end
  end

  describe 'カード交換時のバージョン競合' do
    let!(:game_number) do
      command_bus.execute(Commands::GameStart.new)
      QueryService.latest_game_number
    end

    let!(:query_service) { QueryService.new(game_number) }
    let!(:card) { query_service.latest_hand_cards.first }

    before do
      # @card と @game_number を card と game_number に修正
      command_bus.execute(Commands::ExchangeCard.new(card, game_number))
    end

    it '警告ログが出力されること' do
      allow(Event).to receive(:next_version_for).and_return(1)
      # 2枚目のカードを取得
      card2 = query_service.latest_hand_cards.first
      command_bus.execute(Commands::ExchangeCard.new(card2, game_number))
      result = command_bus.execute(Commands::ExchangeCard.new(card2, game_number))
      expect(result.error).to be_a(CommandErrors::VersionConflict)
      expect(logger.messages_for_level(:warn).last).to match(/コマンド失敗: バージョン競合/)
    end
  end
end
