# frozen_string_literal: true

class VersionConflictEvent
  attr_reader :expected_version, :actual_version

  def initialize(expected_version, actual_version)
    @expected_version = expected_version
    @actual_version = actual_version
  end

  def self.event_type
    'version_conflict'
  end

  delegate :event_type, to: :class

  def to_event_data
    {
      event_type: event_type,
      expected_version: expected_version,
      actual_version: actual_version
    }
  end

  def to_serialized_hash
    to_event_data
  end

  def self.from_store(store)
    event_data = JSON.parse(store.event_data, symbolize_names: true)
    new(
      event_data[:expected_version],
      event_data[:actual_version]
    )
  end
end
