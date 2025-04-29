class CreateGameStateStates < ActiveRecord::Migration[8.0]
  def change
    create_table :game_state_states do |t|
      t.jsonb  :hand_set, null: false
      t.string :current_rank, null: false
      t.integer :current_turn, null: false
      t.integer :status, null: false
      t.timestamps
    end
  end
end
