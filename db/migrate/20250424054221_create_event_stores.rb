class CreateEventStores < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.string   :event_type, null: false
      t.jsonb    :event_data, null: false
      t.datetime :occurred_at, null: false
      t.integer  :version, null: false
      t.timestamps
    end
  end
end
