class AddColumnsToGameState < ActiveRecord::Migration[8.0]
  def change
    add_column :game_states, :hand_1, :string, null: false
    add_column :game_states, :hand_2, :string, null: false
    add_column :game_states, :hand_3, :string, null: false
    add_column :game_states, :hand_4, :string, null: false
    add_column :game_states, :hand_5, :string, null: false
    add_column :game_states, :current_rank, :string, null: false
    add_column :game_states, :current_turn, :integer, null: false
  end
end
