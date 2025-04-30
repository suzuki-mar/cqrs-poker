# frozen_string_literal: true

module FailureEvents
  class InvalidCommand
    def initialize(command:, reason:)
      @command = command
      @reason = reason
    end

    def self.event_type
      'invalid_command_event'
    end

    delegate :event_type, to: :class

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

    def self.from_store(store)
      event_data = JSON.parse(store.event_data, symbolize_names: true)
      new(command: event_data[:command], reason: event_data[:reason])
    end
  end
end
