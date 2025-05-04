# frozen_string_literal: true

module CommandHandlers
  class EndGame
    def initialize(event_bus)
      @event_bus = event_bus
      @aggregate_store = Aggregates::Store.new
    end

    def handle(command, context)
      raise ArgumentError, 'このハンドラーはEND_GAME専用です' unless context.type == CommandContext::Types::END_GAME

      unless aggregate_store.game_in_progress?
        return { success: false, error: CommandErrors::InvalidCommand.new(command: command, reason: 'ゲームが進行中ではありません') }
      end

      board = Aggregates::BoardAggregate.load_for_current_state
      command.execute_for_end_game(board)
      event = SuccessEvents::GameEnded.new
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
