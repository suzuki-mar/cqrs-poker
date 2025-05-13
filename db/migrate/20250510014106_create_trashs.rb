class CreateTrashs < ActiveRecord::Migration[8.0]
  def change
    create_table :trashes do |t|
      t.jsonb :discarded_cards, null: false
      t.integer :current_turn, null: false
      t.integer :last_event_id, null: false

      t.timestamps
    end
  end
end
