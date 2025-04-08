# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommandHandler do
  let(:command_handler) { described_class.new }

  describe "#handle" do
    it "コマンドを実行できること" do
      result = command_handler.handle(GameStartCommand)
      expect(result).not_to be_nil
    end
  end
end
