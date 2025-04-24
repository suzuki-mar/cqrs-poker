# frozen_string_literal: true

class VersionConflictEvent
  EVENT_TYPE = 'version_conflict'

  attr_reader :event_type, :expected_version, :actual_version

  def initialize(event_type, expected_version = {}, actual_version = {})
    @event_type = event_type
    @expected_version = expected_version
    @actual_version = actual_version
  end

  def event_type
    EVENT_TYPE
  end

  def event_type_name
    EVENT_TYPE
  end

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
end
