# frozen_string_literal: true

module HandlerStrategy
  class ExchangeCard
    def initialize(command, context, board, aggregate_store)
      @command = command
      @context = context
      @board = board
      @aggregate_store = aggregate_store
    end

    # rubocop:disable Metrics/MethodLength
    # 状態遷移の全体像を一目で把握できるよう、あえてメソッド分割せずインラインで記述しています。
    # （現状の規模・責務ならこの方が可読性・保守性が高いため）
    def build_invalid_command_event_if_needed
      unless aggregate_store.game_already_started?
        return InvalidCommandEvent.new(command: command, reason: 'ゲームが終了しています')
      end

      events = aggregate_store.load_all_events_in_order

      cards = [] # @type var cards: Array[_CardForCommand]
      events.each do |event|
        if event.is_a?(GameStartedEvent)
          cards = event.to_event_data[:initial_hand].map do |c|
            HandSet.build_card_for_command(c.is_a?(HandSet::Card) ? c.to_s : c)
          end
        elsif event.is_a?(CardExchangedEvent)
          cards = build_cards_from_exchanged_event(cards, event)
        end
      end

      build_invalid_command_event_if_unexchangeable(cards)
    end
    # rubocop:enable Metrics/MethodLength

    def build_event_by_executing
      discarded_card = context.discarded_card
      raise ArgumentError, 'discarded_cardがnilです' if discarded_card.nil?

      new_card = command.execute_for_exchange_card(board)
      CardExchangedEvent.new(discarded_card, new_card)
    end

    private

    def build_invalid_command_event_if_unexchangeable(cards)
      discarded_card = context.discarded_card
      raise ArgumentError, 'discarded_cardがnilです' if discarded_card.nil?

      unless cards.include?(discarded_card)
        return InvalidCommandEvent.new(command: command,
                                       reason: '交換対象のカードが手札に存在しません')
      end
      InvalidCommandEvent.new(command: command, reason: 'デッキの残り枚数が不足しています') unless board.drawable?
    end

    def build_cards_from_exchanged_event(cards, event)
      idx = cards.find_index { |c| c == event.discarded_card }
      return cards unless idx

      new_cards = cards.dup # @type var new_cards: Array[_CardForCommand]
      new_cards[idx] = event.new_card
      new_cards
    end

    attr_reader :command, :context, :board, :aggregate_store
  end
end
