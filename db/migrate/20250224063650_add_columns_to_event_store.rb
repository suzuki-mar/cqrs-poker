class AddColumnsToEventStore < ActiveRecord::Migration[8.0]
  def change
    add_column :event_stores, :event_type, :string, null: false
    add_column :event_stores, :event_data, :jsonb, null: false
    add_column :event_stores, :occurred_at, :datetime, null: false
  end
end
