class ChangeEventVersionUniqueIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index :events, :version
    add_index :events, %i[game_number version], unique: true
  end
end
