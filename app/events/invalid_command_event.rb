# frozen_string_literal: true

class InvalidCommandEvent
  EVENT_TYPE = 'invalid_command_event'

  def initialize(command:, reason:)
    @command = command
    @reason = reason
  end

  def event_type
    EVENT_TYPE
  end

  def event_type_name
    EVENT_TYPE
  end

  def to_event_data
    {
      command: command,
      reason: reason
    }
  end

  # DB保存用
  def to_serialized_hash
    {
      command: command,
      reason: reason
    }
  end

  attr_reader :command, :reason
end
