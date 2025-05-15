# frozen_string_literal: true

module Aggregates
  class Store
    class ErrorBuilder
      def self.version_conflict_result(expected_current_version)
        current_stored_version = Event.maximum(:version) || 0
        return nil if expected_current_version == current_stored_version

        error = CommandErrors::VersionConflict.new(current_stored_version, expected_current_version)
        CommandResult.new(error: error)
      end

      def self.validation_error(error, command)
        raise ArgumentError, 'Command parameter is required for build_validation_error' if command.nil?

        CommandErrors::InvalidCommand.new(
          command: command,
          reason: error.record.errors.full_messages.join(', ')
        )
      end
    end
  end
end
