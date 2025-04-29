class MigrateHandColumnsToHandSetInPlayerHandStates < ActiveRecord::Migration[6.1]
  def change
    # hand_setカラム（JSONB型, null不可, デフォルト空配列）を追加
    add_column :player_hand_states, :hand_set, :jsonb, null: false, default: []

    # hand1〜hand5カラムを削除
    remove_column :player_hand_states, :hand1, :string, null: false
    remove_column :player_hand_states, :hand2, :string, null: false
    remove_column :player_hand_states, :hand3, :string, null: false
    remove_column :player_hand_states, :hand4, :string, null: false
    remove_column :player_hand_states, :hand5, :string, null: false
  end
end
