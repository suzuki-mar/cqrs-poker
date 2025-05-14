# rubocop:disable Rails/NotNullColumn
class AddGameIdToAllTables < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :game_number, :integer, null: false
    add_index  :events, :game_number

    add_column :histories, :game_number, :integer, null: false
    add_index  :histories, :game_number

    add_column :player_hand_states, :game_number, :integer, null: false
    add_index  :player_hand_states, :game_number

    add_column :trash_states, :game_number, :integer, null: false
    add_index  :trash_states, :game_number

    add_column :projection_versions, :game_number, :integer, null: false
    add_index  :projection_versions, :game_number
  end
end
# rubocop:enable Rails/NotNullColumn
