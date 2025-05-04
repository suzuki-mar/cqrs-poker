class CommandBus
  def initialize(event_bus, logger = nil)
    @game_start_handler = CommandHandlers::GameStart.new(event_bus)
    @exchange_card_handler = CommandHandlers::ExchangeCard.new(event_bus)
    @end_game_handler = CommandHandlers::EndGame.new(event_bus)
    @logger = logger
  end

  def execute(command, context)
    result = case context.type
             when CommandContext::Types::GAME_START
               @game_start_handler.handle(command, context)
             when CommandContext::Types::EXCHANGE_CARD
               @exchange_card_handler.handle(command, context)
             when CommandContext::Types::END_GAME
               @end_game_handler.handle(command, context)
             else
               raise ArgumentError, "未対応のコマンドタイプです: #{context.type}"
             end

    if logger && result.is_a?(Hash) && result[:error]
      case result[:error]
      when CommandErrors::InvalidCommand
        logger.warn "[警告] コマンド失敗: #{result[:error].reason}"
      when CommandErrors::VersionConflict
        logger.warn '[警告] コマンド失敗: バージョン競合'
      end
    end
    result
  end

  private

  attr_reader :game_start_handler, :exchange_card_handler, :end_game_handler, :logger
end
