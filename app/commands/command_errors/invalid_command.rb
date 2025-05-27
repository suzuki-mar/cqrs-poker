# frozen_string_literal: true

module CommandErrors
  class InvalidCommand
    GAME_NOT_IN_PROGRESS = :game_not_in_progress
    GAME_ALREADY_ENDED = :game_already_ended
    GAME_NOT_FOUND = :game_not_found

    INVALID_CARD = :invalid_card
    CARD_NOT_FOUND = :card_not_found

    VALIDATION_ERROR = :validation_error

    UNKNOWN_COMMAND = :unknown_command
    INVALID_SELECTION = :invalid_selection
    NO_CARDS_LEFT = :no_cards_left

    attr_reader :command, :message, :error_code

    def initialize(command:, error_code:)
      @command = command

      messages = {
        CommandErrors::InvalidCommand::GAME_NOT_FOUND => '指定されたゲームが存在しません',
        CommandErrors::InvalidCommand::GAME_NOT_IN_PROGRESS => 'ゲームが進行中ではありません',
        CommandErrors::InvalidCommand::NO_CARDS_LEFT => 'デッキの残り枚数が不足しています',
        CommandErrors::InvalidCommand::CARD_NOT_FOUND => '交換対象のカードが手札に存在しません',
        CommandErrors::InvalidCommand::GAME_ALREADY_ENDED => 'すでにゲームが終了しています'
      }

      @message = messages[error_code]
      @error_code = error_code
    end
  end
end
