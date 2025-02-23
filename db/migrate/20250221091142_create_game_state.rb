class CreateGameState < ActiveRecord::Migration[8.0]
  def change
    create_table :game_states do |t|
      t.timestamps
    end
  end
end
