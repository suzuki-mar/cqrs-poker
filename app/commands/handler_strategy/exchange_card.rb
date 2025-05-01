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
      unless aggregate_store.game_in_progress?
        return FailureEvents::InvalidCommand.new(command: command, reason: 'ゲームが進行中ではありません')
      end

      events = aggregate_store.load_all_events_in_order
      hand = events.reduce([]) { |acc, event| rebuild_hand_from_event(acc, event) }
      build_invalid_command_event_if_unexchangeable(hand)
    end

    def build_event_by_executing
      discarded_card = context.discarded_card
      raise ArgumentError, 'discarded_cardがnilです' if discarded_card.nil?

      new_card = command.execute_for_exchange_card(board)
      SuccessEvents::CardExchanged.new(discarded_card, new_card)
    end

    private

    def rebuild_hand_from_event(hand, event)
      if event.is_a?(SuccessEvents::GameStarted)
        hand = event.to_event_data[:initial_hand].map do |c|
          HandSet.build_card_for_command(c.is_a?(HandSet::Card) ? c.to_s : c)
        end
      elsif event.is_a?(SuccessEvents::CardExchanged)
        hand = build_cards_from_exchanged_event(hand, event)
      end
      hand
    end

    def build_invalid_command_event_if_unexchangeable(hand)
      discarded_card = context.discarded_card
      raise ArgumentError, 'discarded_cardがnilです' if discarded_card.nil?

      unless hand.include?(discarded_card)
        return FailureEvents::InvalidCommand.new(command: command,
                                                 reason: '交換対象のカードが手札に存在しません')
      end
      FailureEvents::InvalidCommand.new(command: command, reason: 'デッキの残り枚数が不足しています') unless board.drawable?
    end

    def build_cards_from_exchanged_event(hand, event)
      idx = hand.find_index { |c| c == event.to_event_data[:discarded_card] }
      return hand unless idx

      new_hand = hand.dup # @type var new_hand: Array[_CardForCommand]
      new_hand[idx] = event.to_event_data[:new_card]
      new_hand
    end

    attr_reader :command, :context, :board, :aggregate_store
  end
end
