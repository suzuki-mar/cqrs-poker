# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommandHandler do
  let(:event_publisher) do
    EventPublisher.new(
      projection: Projection.new,
      event_listener: LogEventListener.new(TestLogger.new)
    )
  end

  let(:event_bus) { EventBus.new(event_publisher) }
  let(:command_handler) { described_class.new(event_bus) }

  describe "#handle" do
    it "コマンドを実行し、イベントを発行できること" do
      allow(event_publisher).to receive(:broadcast)

      event = command_handler.handle(Command.new, CommandContext.build_for_game_start)

      expect(event).to be_a(GameStartedEvent)
      expect(event_publisher).to have_received(:broadcast)
    end
  end
end
