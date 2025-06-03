# frozen_string_literal: true

module Aggregates
  class Store
    class ErrorResultBuilder
      def self.version_conflict(game_number, expected_current_version)
        current_stored_version = Event.current_version_for_game(game_number)

        error = CommandErrors::VersionConflict.new(current_stored_version, expected_current_version)
        CommandResult.new(error: error)
      end

      def self.validation_error(_error, command)
        CommandResult.new(
          error: CommandErrors::InvalidCommand.new(
            command: command,
            error_code: CommandErrors::InvalidCommand::VALIDATION_ERROR
          )
        )
      end
    end
  end
end
