# frozen_string_literal: true

module EventListener
  class Log
    def initialize(logger = Rails.logger)
      @logger = logger
    end

    def handle_event(event)
      warning_message = MessageBuilder.build_warning_message_if_needed(event)
      if warning_message
        logger.warn warning_message
        return
      end

      info_message = MessageBuilder.build_info_message(event)
      logger.info info_message
    end

    private

    attr_reader :logger
  end
end
