# frozen_string_literal: true

module CommandHandlers
  class GameStart
    def initialize(event_bus)
      @event_bus = event_bus
      @aggregate_store = Aggregates::Store.new
    end

    def handle(command, context)
      raise ArgumentError, 'このハンドラーはGAME_START専用です' unless context.type == CommandContext::Types::GAME_START

      if aggregate_store.game_in_progress?
        expected_version = aggregate_store.current_version + 1
        actual_version = aggregate_store.current_version
        return { success: false, error: CommandErrors::VersionConflict.new(expected_version, actual_version) }
      end

      board = Aggregates::BoardAggregate.load_for_current_state
      initial_hand = command.execute_for_game_start(board)
      event = SuccessEvents::GameStarted.new(initial_hand)
      result = append_to_aggregate_store(event, command)
      event_obj = result[:event] if result[:success]
      error_obj = result[:error] unless result[:success]
      if result[:success] == true && event_obj
        case event_obj
        when SuccessEvents::GameStarted, SuccessEvents::GameEnded, SuccessEvents::CardExchanged
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

    def append_to_aggregate_store(event, command)
      result = aggregate_store.append(event, aggregate_store.current_version)
      event_obj = result[:event] if result[:success]
      error_obj = result[:error] unless result[:success]
      if result.is_a?(Hash)
        if result[:success] == true && event_obj
          case event_obj
          when SuccessEvents::GameStarted, SuccessEvents::GameEnded, SuccessEvents::CardExchanged
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
