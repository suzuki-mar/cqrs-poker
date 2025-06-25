class AddUniqueConstraintToPlayerHandStates < ActiveRecord::Migration[8.0]
  def change
    add_index :player_hand_states, :game_number, unique: true, name: 'index_player_hand_states_on_game_number_unique'
  end
end
