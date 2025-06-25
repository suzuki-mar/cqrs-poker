# frozen_string_literal: true

module CommandErrors
  class InvalidCommand < StandardError
    GAME_NOT_IN_PROGRESS = :game_not_in_progress
    GAME_ALREADY_ENDED = :game_already_ended
    GAME_NOT_FOUND = :game_not_found

    INVALID_CARD = :invalid_card
    CARD_NOT_FOUND = :card_not_found
    EXCHANGE_LIMIT_EXCEEDED = :exchange_limit_exceeded

    VALIDATION_ERROR = :validation_error

    UNKNOWN_COMMAND = :unknown_command
    INVALID_SELECTION = :invalid_selection
    NO_CARDS_LEFT = :no_cards_left

    ERROR_MESSAGES = {
      GAME_NOT_FOUND => '指定されたゲームが存在しません',
      GAME_NOT_IN_PROGRESS => 'ゲームが進行中ではありません',
      NO_CARDS_LEFT => 'デッキの残り枚数が不足しています',
      CARD_NOT_FOUND => '交換対象のカードが手札に存在しません',
      GAME_ALREADY_ENDED => 'すでにゲームが終了しています',
      INVALID_CARD => '無効なカードです',
      VALIDATION_ERROR => 'バリデーションエラーが発生しました',
      UNKNOWN_COMMAND => '不明なコマンドです',
      INVALID_SELECTION => '無効な選択です',
      EXCHANGE_LIMIT_EXCEEDED => 'カード交換の上限回数に達しました'
    }.freeze

    private_constant :ERROR_MESSAGES

    attr_reader :command, :message, :error_code

    def initialize(command:, error_code:)
      @command = command
      @message = ERROR_MESSAGES.fetch(error_code, '不明なエラーが発生しました')
      @error_code = error_code
      super(message)
    end
  end
end
