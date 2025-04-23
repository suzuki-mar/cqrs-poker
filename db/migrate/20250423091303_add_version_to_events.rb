class AddVersionToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :version, :integer
    add_index :events, :version, unique: true
  end
end
