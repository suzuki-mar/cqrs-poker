# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommandHandler do
  let(:event_publisher) { double('EventPublisher') }
  let(:event_bus) { EventBus.new(event_publisher) }
  let(:command_handler) { described_class.new(event_bus) }

  describe "#handle" do
    it "コマンドを実行できること" do
      allow(event_publisher).to receive(:broadcast)

      command_handler.handle(GameStartCommand)

      expect(GameState.last).to have_attributes(status: "started")
    end
  end
end
