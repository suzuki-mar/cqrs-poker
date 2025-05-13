module ReadModels
  class TrashState
    def self.load
      new(Query::TrashState.current_game)
    end

    # def has_number?(card)
    #   raise 'trash_state is nil' if empty?
    #
    #   # @type var trash_state: Query::TrashState
    #   trash_state = @trash_state
    #   trash_state.discarded_cards.any? { |c| HandSet::Card.new(c).same_number?(card) }
    # end

    def accept!(card, current_turn, last_event_id)
      if empty?
        @trash_state = Query::TrashState.create!(
          discarded_cards: [card.to_s],
          current_turn: current_turn,
          last_event_id: last_event_id
        )
      else
        # @type var trash_state: Query::TrashState
        trash_state = @trash_state
        trash_state.discarded_cards << card.to_s
        trash_state.save!
      end
    end

    def current_turn
      raise 'trash_state is nil' if empty?

      # @type var trash_state: Query::TrashState
      trash_state = self.trash_state
      trash_state.current_turn
    end

    def last_event_id
      raise 'trash_state is nil' if empty?

      # @type var trash_state: Query::TrashState
      trash_state = self.trash_state
      EventId.new(trash_state.last_event_id)
    end

    def number?(card)
      raise 'trash_state is nil' if empty?

      # @type var trash_state: Query::TrashState
      trash_state = @trash_state
      trash_state.discarded_cards.any? { |c| HandSet::Card.new(c).same_number?(card) }
    end

    private

    attr_reader :trash_state

    def initialize(trash_state)
      @trash_state = trash_state
    end

    def empty?
      @trash_state.nil?
    end
  end
end
