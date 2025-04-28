class AddUniqueIndexToEventsVersion < ActiveRecord::Migration[6.0]
  def change
    add_index :events, :version, unique: true
  end
end
