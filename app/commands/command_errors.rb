# frozen_string_literal: true

module CommandErrors
  class VersionConflict
    attr_reader :expected_version, :actual_version

    def initialize(expected_version, actual_version)
      @expected_version = expected_version
      @actual_version = actual_version
    end
  end

  class InvalidCommand
    attr_reader :command, :reason

    def initialize(command:, reason:)
      @command = command
      @reason = reason
    end
  end
end
