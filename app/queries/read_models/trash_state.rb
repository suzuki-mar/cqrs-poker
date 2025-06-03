# frozen_string_literal: true

# @dynamic discarded_cards, current_turn
module ReadModels
  class TrashState
    attr_reader :game_number

    delegate :discarded_cards, :current_turn, to: :trash_record

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

    def accept!(card, current_turn, last_event_id)
      record = Query::TrashState.current_game(game_number)
      raise "TrashState record not found for game_number: #{game_number.value}" unless record

      record.discarded_cards << card.to_s

      record.current_turn = current_turn
      record.last_event_id = last_event_id

      record.save!
    end

    def exists?
      Query::TrashState.current_game(game_number).present?
    end

    def empty?
      !exists? || trash_record.discarded_cards.empty?
    end

    def number?(card)
      trash_record.discarded_cards.any? do |c|
        # 警告エラーがでるのでコメントを付けている
        # @type var c: String
        HandSet::Card.new(c).same_number?(card)
      end
    end

    def count_same_rank_by_card(card)
      trash_record.discarded_cards.count do |c|
        # @type var c: String
        HandSet::Card.new(c).number == card.number
      end
    end

    def count_same_suit_by_card(card)
      trash_record.discarded_cards.count do |c|
        # @type var c: String
        HandSet::Card.new(c).suit == card.suit
      end
    end

    def last_event_id
      EventId.new(trash_record.last_event_id)
    end

    private

    def trash_record
      return @trash_record unless @trash_record.nil?

      record = Query::TrashState.current_game(game_number)
      raise "TrashState record not found for game_number: #{game_number.value}" unless record

      @trash_record = record
      @trash_record
    end
  end
end
