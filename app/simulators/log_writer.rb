# frozen_string_literal: true

class LogWriter
  def initialize(logger)
    @logger = logger
  end

  def initial_hand(hand_set)
    hand_cards = hand_set.cards.map(&:to_s)
    @logger.info "初期手札: #{hand_cards.join(' ')} を最初に引きました"
  end

  def event_processed(event_class_name)
    @logger.info "Simulator: イベント[#{event_class_name}]を処理しました。"
  end

  def command_failure_handled(error_message)
    @logger.error "[HANDLER] コマンド失敗がハンドルされました: #{error_message}"
  end

  private

  attr_reader :logger
end
