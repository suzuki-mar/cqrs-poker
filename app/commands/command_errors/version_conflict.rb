# frozen_string_literal: true

module CommandErrors
  class VersionConflict < StandardError
    attr_reader :expected_version, :actual_version

    def initialize(expected_version, actual_version)
      @expected_version = expected_version
      @actual_version = actual_version
      super("バージョンの競合が発生しました。期待されたバージョン: #{expected_version}, 実際のバージョン: #{actual_version}")
    end
  end
end
