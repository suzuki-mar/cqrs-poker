# frozen_string_literal: true

module HandlerStrategy
  class ExchangeCard
    def initialize(command, context, board)
      @command = command
      @context = context
      @board = board
    end

    def build_invalid_command_event_if_needed
      discarded_card = context.discarded_card
      current_game_state = GameState.find_current_session
      return InvalidCommandEvent.new(command: command, reason: 'ゲーム状態が存在しません') if current_game_state.nil?

      hand_set = ReadModels::HandSet.build(current_game_state.hand_set.map { |str| Card.new(str) })

      unless hand_set.include?(discarded_card)
        return InvalidCommandEvent.new(command: command, reason: '交換対象のカードが手札に存在しません')
      end

      return InvalidCommandEvent.new(command: command, reason: 'デッキの残り枚数が不足しています') unless board.drawable?

      nil
    end

    def build_event_by_executing
      discarded_card = context.discarded_card
      new_card = command.execute_for_exchange_card(board)
      CardExchangedEvent.new(discarded_card, new_card)
    end

    private

    attr_reader :command, :context, :board
  end
end
