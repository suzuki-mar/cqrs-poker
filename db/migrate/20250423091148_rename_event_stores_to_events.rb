class RenameEventStoresToEvents < ActiveRecord::Migration[8.0]
  def change
    rename_table :event_stores, :events
  end
end
