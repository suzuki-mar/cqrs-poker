# frozen_string_literal: true

class LogEventListener
  def initialize(logger = Rails.logger)
    @logger = logger
  end

  def handle_event(event)
    case event
    when GameStartedEvent
      logger.info format_event_message("ゲーム開始", format_cards(event.initial_hand.cards))
    else
      logger.info format_event_message(event.class.name)
    end
  end

  private

  attr_reader :logger

  def format_event_message(event_type, details = nil)
    message = "イベント受信: #{event_type}"
    message += " | #{details}" if details
    message
  end

  def format_cards(cards)
    "手札: #{cards.map(&:to_s).join(', ')}"
  end
end
