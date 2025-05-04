# frozen_string_literal: true

module CommandHandlers
  class ExchangeCard
    def initialize(event_bus)
      @event_bus = event_bus
      @aggregate_store = Aggregates::Store.new
    end

    def handle(command, context)
      raise ArgumentError, 'このハンドラーはEXCHANGE_CARD専用です' unless context.type == CommandContext::Types::EXCHANGE_CARD

      unless aggregate_store.game_in_progress?
        return { success: false, error: CommandErrors::InvalidCommand.new(command: command, reason: 'ゲームが進行中ではありません') }
      end

      board = Aggregates::BoardAggregate.load_for_current_state
      discarded_card = context.discarded_card
      raise ArgumentError, 'discarded_cardがnilです' if discarded_card.nil?

      events = aggregate_store.load_all_events_in_order
      hand = events.reduce([]) { |acc, event| rebuild_hand_from_event(acc, event) }

      unless hand.include?(discarded_card)
        return { success: false,
                 error: CommandErrors::InvalidCommand.new(command: command, reason: '交換対象のカードが手札に存在しません') }
      end

      unless board.drawable?
        return { success: false,
                 error: CommandErrors::InvalidCommand.new(command: command, reason: 'デッキの残り枚数が不足しています') }
      end

      new_card = command.execute_for_exchange_card(board)
      event = SuccessEvents::CardExchanged.new(discarded_card, new_card)
      result = append_to_aggregate_store(event, command)
      event_obj = result[:event] if result[:success]
      error_obj = result[:error] unless result[:success]
      if result[:success] == true && event_obj
        case event_obj
        when SuccessEvents::CardExchanged, SuccessEvents::GameStarted, SuccessEvents::GameEnded
          event_bus.publish(event_obj)
          { success: true, event: event_obj }
        else
          raise "[BUG] handle: event_objが想定外の型: \\#{event_obj}"
        end
      elsif result[:success] == false && error_obj
        case error_obj
        when CommandErrors::InvalidCommand, CommandErrors::VersionConflict
          { success: false, error: error_obj }
        else
          raise "[BUG] handle: error_objが想定外の型: \\#{error_obj}"
        end
      else
        raise "[BUG] handle: 型通りでない返り値: \\#{result.inspect}"
      end
    end

    private

    attr_reader :event_bus, :aggregate_store

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

    def build_cards_from_exchanged_event(hand, event)
      idx = hand.find_index { |c| c == event.to_event_data[:discarded_card] }
      return hand unless idx

      new_hand = hand.dup
      new_hand[idx] = event.to_event_data[:new_card]
      new_hand
    end

    def append_to_aggregate_store(event, command)
      result = aggregate_store.append(event, aggregate_store.current_version)
      event_obj = result[:event] if result[:success]
      error_obj = result[:error] unless result[:success]
      if result.is_a?(Hash)
        if result[:success] == true && event_obj
          case event_obj
          when SuccessEvents::CardExchanged, SuccessEvents::GameStarted, SuccessEvents::GameEnded
            return { success: true, event: event_obj }
          else
            raise "[BUG] append_to_aggregate_store: event_objが想定外の型: \\#{event_obj}"
          end
        elsif result[:success] == false && error_obj
          case error_obj
          when CommandErrors::InvalidCommand, CommandErrors::VersionConflict
            return { success: false, error: error_obj }
          else
            raise "[BUG] append_to_aggregate_store: error_objが想定外の型: \\#{error_obj}"
          end
        end
      end
      raise "[BUG] append_to_aggregate_store: 型通りでない返り値: \\#{result.inspect}"
    rescue ActiveRecord::RecordInvalid => e
      error_event = aggregate_store.build_validation_error(e, command)
      { success: false, error: error_event }
    end
  end
end
