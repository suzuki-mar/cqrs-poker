class CreatePlayerHandStates < ActiveRecord::Migration[8.0]
  def change
    create_table :player_hand_states do |t|
      t.jsonb  :hand_set, null: false
      t.string :current_rank, null: false
      t.integer :current_turn, null: false
      t.integer :status, null: false
      t.timestamps
    end
  end
end
