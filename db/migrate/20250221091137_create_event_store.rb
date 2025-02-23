class CreateEventStore < ActiveRecord::Migration[8.0]
  def change
    create_table :event_stores do |t|
      t.timestamps
    end
  end
end
