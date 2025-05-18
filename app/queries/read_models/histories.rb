module ReadModels
  class Histories
    def self.load(game_number)
      Query::History.where(game_number: game_number.value)
    end

    def self.add(hand_set, event)
      Query::History.create!(
        game_number: event.game_number.value,
        last_event_id: event.event_id.value,
        hand_set: hand_set.cards.map(&:to_s),
        rank: HandSet::Rank::ALL.index(hand_set.evaluate),
        ended_at: event.to_event_data[:ended_at]
      )
    end
  end
end
