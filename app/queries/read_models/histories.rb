module ReadModels
  class Histories
    def self.load(limit: 10)
      Query::History.order(ended_at: :desc).limit(limit)
    end

    def self.add(hand_set, event_id)
      Query::History.create!(
        hand_set: hand_set.cards.map(&:to_s),
        rank: HandSet::Rank::ALL.index(hand_set.evaluate),
        ended_at: Time.current,
        last_event_id: event_id
      )
    end
  end
end
