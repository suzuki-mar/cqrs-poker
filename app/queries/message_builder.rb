# frozen_string_literal: true

class MessageBuilder
  def self.build_info_message(event)
    case event
    when GameStartedEvent
      format_event_message('ゲーム開始', format_cards(event.to_event_data[:initial_hand].map(&:to_s)))
    when CardExchangedEvent
      format_event_message(
        'カード交換',
        "捨てたカード: #{event.to_event_data[:discarded_card]}, 引いたカード: #{event.to_event_data[:new_card]}"
      )
    when GameEndedEvent
      format_event_message('ゲーム終了')
    else
      format_event_message(event.class.name)
    end
  end

  def self.build_warning_message_if_needed(event)
    case event
    when CommandErrors::InvalidCommand
      format_event_message('不正な選択肢の選択', event.reason)
    when CommandErrors::VersionConflict
      expected = event.expected_version
      actual   = event.actual_version
      details  = "expected: #{expected}, actual: #{actual}"
      format_event_message('バージョン競合', details)
    end
  end

  def self.format_event_message(event_type, details = nil)
    message = "イベント受信: #{event_type}"
    message += " | #{details}" if details
    message
  end

  def self.format_cards(cards)
    "手札: #{cards.map(&:to_s).join(', ')}"
  end
end
