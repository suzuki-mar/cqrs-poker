class RenameTrashesToTrashStates < ActiveRecord::Migration[8.0]
  def change
    rename_table :trashes, :trash_states
  end
end
