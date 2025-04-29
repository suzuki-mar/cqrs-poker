class RenameGameStatesToPlayerHandStates < ActiveRecord::Migration[6.1]
  def change
    rename_table :game_states, :player_hand_states
  end
end
