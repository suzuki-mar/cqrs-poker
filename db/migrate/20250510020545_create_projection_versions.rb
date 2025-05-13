class CreateProjectionVersions < ActiveRecord::Migration[8.0]
  def change
    create_table :projection_versions do |t|
      t.integer :event_id, null: false
      t.string :projection_name, null: false

      t.timestamps
    end
  end
end
