# frozen_string_literal: true

module SuccessEvents
  class CardExchanged
    def initialize(discarded_card, new_card)
      @discarded_card = discarded_card
      @new_card = new_card
    end

    def self.event_type
      'card_exchanged'
    end

    delegate :event_type, to: :class

    def to_event_data
      {
        discarded_card: discarded_card,
        new_card: new_card
      }
    end

    # DB保存用
    def to_serialized_hash
      {
        discarded_card: discarded_card.to_s,
        new_card: new_card.to_s
      }
    end

    def self.from_store(store)
      event_data = JSON.parse(store.event_data, symbolize_names: true)
      discarded = HandSet.build_card_for_command(event_data[:discarded_card])
      new_c = HandSet.build_card_for_command(event_data[:new_card])
      new(discarded, new_c)
    end

    private

    attr_reader :discarded_card, :new_card
  end
end
