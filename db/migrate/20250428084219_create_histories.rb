class CreateHistories < ActiveRecord::Migration[8.0]
  def change
    create_table :histories do |t|
      t.jsonb :hand_set
      t.integer :rank
      t.datetime :ended_at
      t.integer :last_event_id, null: false

      t.timestamps
    end
    add_index :histories, :ended_at
  end
end
