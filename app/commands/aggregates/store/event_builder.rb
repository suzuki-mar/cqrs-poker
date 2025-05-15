module Aggregates
  class Store
    class EventBuilder
      class << self
        MAPPINGS = {
          GameStartedEvent.event_type => GameStartedEvent,
          CardExchangedEvent.event_type => CardExchangedEvent,
          GameEndedEvent.event_type => GameEndedEvent
        }.freeze
        private_constant :MAPPINGS

        def execute(event_record)
          raise_if_invalid_event_record(event_record, MAPPINGS)
          build_event(event_record, MAPPINGS)
        end

        private

        def raise_if_invalid_event_record(event_record, maps)
          raise "未知のイベントタイプです: #{event_record.event_type}" unless maps.key?(event_record.event_type)

          event = build_event(event_record, maps)
          raise "イベントの復元に失敗しました: #{event_record.event_type}" if event.nil?
          raise "[BUG] build_event_from_record: eventが_Event型でない: #{event}" unless valid_event_type?(event)
        end

        def build_event(event_record, maps)
          event_class = maps[event_record.event_type]
          event_data = JSON.parse(event_record.event_data, symbolize_names: true)
          event_class.from_event_data(
            event_data,
            EventId.new(event_record.id),
            GameNumber.new(event_record.game_number)
          )
        end

        def valid_event_type?(event)
          event.is_a?(GameStartedEvent) ||
            event.is_a?(CardExchangedEvent) ||
            event.is_a?(GameEndedEvent)
        end
      end
    end
  end
end
