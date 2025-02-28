# テストダブル（モック・スタブ）の使用ガイドライン

## テスト用ダミークラスの定義場所

テストで使用するダミークラス（モック、スタブなど）は、テストケースの直下に定義することを推奨します。

```ruby
RSpec.describe SomeClass do
  # テストケースの直下にダミークラスを定義
  class DummyCollaborator
    def perform_action
      "dummy result"
    end
  end
  
  it "collaborates with the dummy" do
    dummy = DummyCollaborator.new
    result = subject.work_with(dummy)
    expect(result).to eq("expected result")
  end
end
```

### メリット

1. **可読性**: テストに関連するすべてのコードが一箇所にまとまる
2. **名前空間の汚染防止**: グローバル名前空間を汚染せず、他のテストとの衝突を防ぐ
3. **テストの独立性**: 各テストが必要なダミークラスを自身で定義するため、テスト間の依存関係が減少
4. **メンテナンス性**: テストを修正する際に、関連するダミークラスも同時に見直せる

### 例外

- 複数のテストで共有する必要があるダミークラスは、`spec/support`ディレクトリに配置
- 大規模なダミークラスは、可読性のために別ファイルに分離することも検討 