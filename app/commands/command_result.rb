# frozen_string_literal: true

class CommandResult
  attr_reader :event, :error

  def initialize(event: nil, error: nil)
    @event = event
    @error = error
  end

  def success?
    !event.nil?
  end

  def failure?
    !error.nil?
  end

  def self.invalid_command(command, reason, error_code)
    new(error: CommandErrors::InvalidCommand.new(command: command, reason: reason, error_code: error_code))
  end
end
