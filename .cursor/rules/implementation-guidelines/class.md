# クラスの実装方針

## ActiveRecord

### バリデーションメソッドの命名規則

#### 学んだこと
- **バリデーションメソッド名には対象フィールドを含めるべき**
  - 例: `validate_occurred_at_not_future_date`
  - これにより、何に対するバリデーションなのかが一目でわかる
- **メソッド名から検証内容が明確にわかるようにする**
  - 単に `validate_occurred_at` ではなく `validate_occurred_at_not_future_date` とする
  - 「何を」検証しているのかが名前から理解できる
- **検証ロジックを実装するメソッドと、それを呼び出すバリデーションメソッドを区別する**
  - 例: `valid_json?`（検証ロジック）と `validate_event_data_json`（バリデーションメソッド）

#### 実装例
```ruby
# 良い例
validate :validate_occurred_at_not_future_date

def validate_occurred_at_not_future_date
  if occurred_at.present? && occurred_at > Time.current
    errors.add(:occurred_at, "can't be in the future")
  end
end

# 避けるべき例
validate :check_date

def check_date
  # 何のフィールドをチェックしているのか不明確
end
```

