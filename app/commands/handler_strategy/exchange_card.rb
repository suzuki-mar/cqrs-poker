# frozen_string_literal: true

module HandlerStrategy
  class ExchangeCard
    def initialize(command, context, board, aggregate_store)
      @command = command
      @context = context
      @board = board
      @aggregate_store = aggregate_store
    end

    def build_invalid_command_event_if_needed
      events = aggregate_store.load_all_events_in_order

      replay_hand = [] # @type var replay_hand: Array[_CardForCommand]
      events.each do |event|
        replay_hand = apply_event_to_replay_hand(replay_hand, event) # @type var replay_hand: Array[_CardForCommand]
      end

      build_invalid_command_event_if_unexchangeable(replay_hand)
    end

    def build_event_by_executing
      discarded_card = context.discarded_card
      raise ArgumentError, 'discarded_cardがnilです' if discarded_card.nil?

      new_card = command.execute_for_exchange_card(board)
      CardExchangedEvent.new(discarded_card, new_card)
    end

    private

    def build_invalid_command_event_if_unexchangeable(hand)
      discarded_card = context.discarded_card
      raise ArgumentError, 'discarded_cardがnilです' if discarded_card.nil?

      unless hand.include?(discarded_card)
        return InvalidCommandEvent.new(command: command,
                                       reason: '交換対象のカードが手札に存在しません')
      end
      InvalidCommandEvent.new(command: command, reason: 'デッキの残り枚数が不足しています') unless board.drawable?
    end

    def apply_event_to_replay_hand(hand, event) # hand: Array[_CardForCommand]として扱う
      case event
      when GameStartedEvent
        event.to_event_data[:initial_hand].map do |c|
          HandSet.build_card_for_command(c.is_a?(HandSet::Card) ? c.to_s : c)
        end
      when CardExchangedEvent
        idx = hand.find_index { |c| c == event.discarded_card }
        if idx
          new_hand = hand.dup # @type var new_hand: Array[_CardForCommand]
          new_hand[idx] = event.new_card
          new_hand
        else
          hand
        end
      else
        hand
      end
    end

    attr_reader :command, :context, :board, :aggregate_store
  end
end
