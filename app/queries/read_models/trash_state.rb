# frozen_string_literal: true

module ReadModels
  class TrashState
    attr_reader :game_number

    def self.load(game_number)
      record = Query::TrashState.current_game(game_number)
      raise "TrashState not found for game_number: \#{game_number.value}" unless record

      new(record)
    end

    def self.prepare!(game_number, first_event_id)
      record = Query::TrashState.new(
        game_number: game_number.value,
        discarded_cards: [],
        current_turn: 1,
        last_event_id: first_event_id.value
      )
      record.save!
    end

    def initialize(record)
      @trash_record = record
      @game_number = GameNumber.new(record.game_number)
    end

    def accept!(card, current_turn, last_event_id, game_number)
      record = Query::TrashState.current_game(game_number)
      raise "TrashState record not found for game_number: #{game_number.value}" unless record

      record.discarded_cards << card.to_s

      record.current_turn = current_turn
      record.last_event_id = last_event_id

      record.save!
    end

    def exists?
      Query::TrashState.current_game(@game_number).present?
    end

    def empty?
      !exists? || trash_record.discarded_cards.empty?
    end

    def number?(card)
      # @type var card: Card
      trash_record.discarded_cards.any? { |c| HandSet::Card.new(c).same_number?(card) }
    end

    delegate :discarded_cards, to: :trash_record

    delegate :current_turn, to: :trash_record

    def last_event_id
      EventId.new(trash_record.last_event_id)
    end

    private

    def trash_record
      if @_trash_record.nil?
        record = Query::TrashState.current_game(@game_number)
        raise "TrashState record not found for game_number: #{@game_number.value}" unless record

        @_trash_record = record
      end
      @_trash_record
    end
  end
end
