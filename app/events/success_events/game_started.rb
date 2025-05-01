module SuccessEvents
  class GameStarted
    def initialize(initial_hand)
      @initial_hand = initial_hand
    end

    def self.event_type
      'game_started'
    end

    delegate :event_type, to: :class

    def to_event_data
      {
        initial_hand: initial_hand.cards,
        evaluate: initial_hand.evaluate
      }
    end

    # DB保存用
    def to_serialized_hash
      {
        initial_hand: initial_hand.cards.map(&:to_s),
        evaluate: initial_hand.evaluate
      }
    end

    def self.from_store(store)
      event_data = JSON.parse(store.event_data, symbolize_names: true)
      hand_data = event_data[:initial_hand]
      hand_cards = hand_data.map { |c| HandSet.build_card_for_query(c) }
      hand_set = HandSet.build(hand_cards)
      new(hand_set)
    end

    private

    attr_reader :initial_hand
  end
end
