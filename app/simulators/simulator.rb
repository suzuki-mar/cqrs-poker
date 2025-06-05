# frozen_string_literal: true

class Simulator
  def initialize(command_bus)
    @command_bus = command_bus
  end

  def start
    game_start_command = Commands::GameStart.new
    result = @command_bus.execute(game_start_command)

    # エラーハンドリング（エラーがある場合はログ出力）
    Rails.logger.error "ゲーム開始に失敗しました: #{result.error}" if result.failure?

    result
  end

  private

  attr_reader :command_bus
end
