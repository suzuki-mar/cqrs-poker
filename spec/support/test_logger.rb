class TestLogger
  LEVELS = %i[debug info warn error fatal].freeze
  LEVEL_MAP = {
    debug: 0,
    info: 1,
    warn: 2,
    error: 3,
    fatal: 4
  }.freeze

  attr_reader :messages
  attr_accessor :level

  def initialize
    clear
    @level = LEVEL_MAP[:debug]  # デフォルトはdebugレベル
  end

  LEVELS.each do |level_name|
    define_method(level_name) do |message|
      return unless LEVEL_MAP[level_name] >= @level
      @messages << { level: level_name, message: message }
    end
  end

  def clear
    @messages = []
  end

  # 一時的にログレベルを変更するブロック
  def silence(temporary_level = :error)
    old_level = @level
    @level = LEVEL_MAP[temporary_level]
    yield
  ensure
    @level = old_level
  end

  # 特定のレベルのメッセージのみを取得
  def messages_for_level(level)
    @messages.select { |msg| msg[:level] == level }.map { |msg| msg[:message] }
  end
end
