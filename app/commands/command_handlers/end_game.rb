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
        return CommandResult.new(event: nil,
                                 error: CommandErrors::InvalidCommand.new(
                                   command: command, reason: 'ゲームが進行中ではありません'
                                 ))
      end

      board = Aggregates::BoardAggregate.load_for_current_state
      command.execute_for_end_game(board)
      event = SuccessEvents::GameEnded.new
      result = append_to_aggregate_store(event, command)
      if result.success?
        event_obj = result.event
        case event_obj
        when SuccessEvents::GameStarted, SuccessEvents::GameEnded, SuccessEvents::CardExchanged
          event_bus.publish(event_obj)
          CommandResult.new(event: event_obj, error: nil)
        else
          raise "[BUG] handle: event_objが想定外の型: \\#{event_obj}"
        end
      else
        error_obj = result.error
        case error_obj
        when CommandErrors::InvalidCommand, CommandErrors::VersionConflict
          CommandResult.new(event: nil, error: error_obj)
        else
          raise "[BUG] handle: error_objが想定外の型: \\#{error_obj}"
        end
      end
    end

    private

    attr_reader :event_bus, :aggregate_store

    def append_to_aggregate_store(event, command)
      aggregate_store.append(event, aggregate_store.current_version)
    rescue ActiveRecord::RecordInvalid => e
      error_event = aggregate_store.build_validation_error(e, command)
      CommandResult.new(event: nil, error: error_event)
    end
  end
end
