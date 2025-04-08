# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommandHandler do
  let(:event_store_domain) { EventStoreDomain.new }
  let(:handler_params) { HandlerParams.new({}) }
  let(:command_handler) { described_class.new(event_store_domain: event_store_domain) }

  describe "#handle" do
    it "コマンドを実行できること" do
      result = command_handler.handle(handler_params)
      expect(result).not_to be_nil
    end
  end
end
