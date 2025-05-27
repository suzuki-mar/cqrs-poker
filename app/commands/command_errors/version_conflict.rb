# frozen_string_literal: true

module CommandErrors
  class VersionConflict
    attr_reader :expected_version, :actual_version

    def initialize(expected_version, actual_version)
      @expected_version = expected_version
      @actual_version = actual_version
    end
  end
end
