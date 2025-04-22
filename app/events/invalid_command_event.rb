# frozen_string_literal: true

class InvalidCommandEvent
  attr_reader :command, :reason

  def initialize(command:, reason:)
    @command = command
    @reason = reason
  end

  def event_type
    "invalid_command_event"
  end

  def to_event_data
    {
      command: command.class.name,
      reason: reason
    }
  end
end
