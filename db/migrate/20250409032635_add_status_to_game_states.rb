class AddStatusToGameStates < ActiveRecord::Migration[8.0]
  def change
    add_column :game_states, :status, :integer, null: false
    add_index :game_states, :status
  end
end
