# frozen_string_literal: true

module AggregateTestHelper
  def self.load_board_aggregate(command_result)
    game_number = command_result.event.game_number
    aggregate_store = Aggregates::Store.new
    aggregate_store.load_board_aggregate_for_current_state(game_number)
  end
end
