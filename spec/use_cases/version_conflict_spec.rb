# frozen_string_literal: true

# バージョン競合は全コマンドで発生しうるため、ユースケースごとに同じ観点でテストをまとめて管理しています。
# - テストの重複や分散を避け、運用・保守の効率を高めるため
# - どのコマンドでも「バージョン競合時の正しいエラー応答・ログ出力」が保証される
# - 新しいユースケース追加時も、このファイルに追記するだけで網羅的な検証が可能です

require 'rails_helper'

RSpec.describe 'バージョン競合ユースケース' do
  let!(:logger) { TestLogger.new }
  let!(:command_bus) { UseCaseHelper.build_command_bus(logger) }
  let!(:game_number) do
    command_bus.execute(Commands::GameStart.new)
    QueryService.latest_game_number
  end
  let!(:query_service) { QueryService.new(game_number) }

  describe 'カード交換時のバージョン競合' do
    before do
      card = query_service.player_hand_set.cards.first
      command_bus.execute(Commands::ExchangeCard.new(card, game_number))
    end

    it '警告ログが出力されること' do
      allow_any_instance_of(Aggregates::Store).to receive(:next_available_version_for_game).and_return(1)
      # 2枚目のカードを取得
      card2 = query_service.player_hand_set.cards.first
      command_bus.execute(Commands::ExchangeCard.new(card2, game_number))
      result = command_bus.execute(Commands::ExchangeCard.new(card2, game_number))
      expect(result.error).to be_a(CommandErrors::VersionConflict)
      expect(logger.messages_for_level(:warn).last).to match(/コマンド失敗: バージョン競合/)
    end

    it 'バージョン競合時にEventレコードが作成されないこと' do
      allow_any_instance_of(Aggregates::Store).to receive(:next_available_version_for_game).and_return(1)

      # 2枚目のカードを取得
      card2 = query_service.player_hand_set.cards.first

      # バージョン競合前のEventレコード数を記録
      event_count_before = Event.count

      # バージョン競合を引き起こすコマンドを実行
      command_bus.execute(Commands::ExchangeCard.new(card2, game_number))
      result = command_bus.execute(Commands::ExchangeCard.new(card2, game_number))

      # バージョン競合でエラーを返すことを検証
      expect(result.error).to be_a(CommandErrors::VersionConflict)

      # Eventレコードが増えていないことを確認
      expect(Event.count).to eq(event_count_before)
    end
  end
end
