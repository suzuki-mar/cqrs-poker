# GameStateからバリデーションを分離している理由：
# GameStateには複数の手札カラム（hand_1〜hand_5）があり、
# 各カラムに同じバリデーションロジックが必要。
# バリデータとして分離することで：
# - 重複したバリデーションコードを避ける
# - GameStateのコードをシンプルに保つ
class HandValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? # presence: true で処理されるため

    card = Card.new(value)
    record.errors.add(attribute, 'カードの表示形式が不正です') unless card.valid?
  end
end
