class CreateGameStateStates < ActiveRecord::Migration[8.0]
  def change
    create_table :game_states do |t|
      t.jsonb  :hand_set, null: false
      t.string :current_rank, null: false
      t.integer :current_turn, null: false
      t.integer :status, null: false
      t.string :hand1, null: false
      t.string :hand2, null: false
      t.string :hand3, null: false
      t.string :hand4, null: false
      t.string :hand5, null: false
      t.timestamps
    end
  end
end
