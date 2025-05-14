module ReadModels
  class TrashState
    def self.load(game_number)
      record = Query::TrashState.current_game(game_number)
      new(record)
    end

    def self.prepare!(game_number, first_event_id)
      # @type var discarded_cards: Array[String]
      discarded_cards = []
      record = Query::TrashState.create!(
        discarded_cards: discarded_cards,
        current_turn: 1,
        last_event_id: first_event_id.value,
        game_number: game_number.value
      )
      new(record)
    end

    def accept!(card, current_turn, last_event_id, game_number)
      return if @trash_state.nil?

      trash_state = @trash_state
      # @type var trash_state: Query::TrashState
      trash_state.discarded_cards << card.to_s
      trash_state.current_turn = current_turn
      trash_state.last_event_id = last_event_id
      trash_state.save!
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

    def empty?
      @trash_state.nil?
    end

    def cards
      return [] if empty?

      trash_state = @trash_state
      # @type var trash_state: Query::TrashState
      trash_state.discarded_cards
    end

    private

    attr_reader :trash_state

    def initialize(trash_state)
      @trash_state = trash_state
    end
  end
end
