# RSpec テスト個別の実装方針

## ActiveRecordモデルのテスト
- 原則として FactoryBot の `create` ではなく `build` を使用
- 例外的なケースを除き、テスト内での直接のインスタンス生成は避ける
- バリデーションやスコープの動作を検証
- データベースの状態に依存するテストは、適切なセットアップとティアダウンを行う

### 例：
```ruby
# 良い例
let(:user) { create(:user) }

# 避けるべき例（例外的なケースを除く）
let(:user) { User.new(name: 'Test User', email: 'test@example.com') }

it "バリデーションが適切に動作する" do
  user.email = ""
  expect(user).to be_invalid
end
```

---

## ドメインクラスのテスト
- 外部依存を持つ場合は適切にモック化
- 期待する振る舞いをテストする

### 例：
```ruby
# 1. まず失敗するテストを書く
describe StartGameUseCase do
  it 'ゲームを開始できる' do
    result = described_class.execute
    expect(result.success?).to be true
    expect(result.game).to be_a(Game)
  end
end

# 2. テストが通る最小限の実装
class StartGameUseCase
  def self.execute
    Result.new(success: true, game: Game.new)
  end
end

# 3. 必要に応じてリファクタリング
```

---

## コントローラーのテスト
- リクエストスペックを中心に実装
- レスポンスのステータスコードと内容を検証
- 認証・認可のテストを含める

### 例：
```ruby
describe "POST /login" do
  it "ログイン成功時にステータス200を返す" do
    post login_path, params: { email: user.email, password: 'password' }
    expect(response).to have_http_status(:ok)
  end
end
```

---

## 振る舞いのテスト
- 実装の詳細ではなく、振る舞いの結果を検証する
- `receive` でメソッド呼び出しを確認するのではなく、結果の状態を確認する

### 例：
```ruby
# 避けるべき書き方（実装の詳細に依存）
expect(record).to receive(:save)

# 推奨される書き方（振る舞いの結果を検証）
expect(record.current_turn).to eq(2)
```

---

## 実装との依存関係の例
- テストが実装の詳細に依存しないようにする

### 例：
```ruby
# 良い例（実装の定数を参照）
it { should validate_inclusion_of(:current_rank).in_array(GameState::VALID_RANKS) }

# 避けるべき例（テスト内で独自に定義）
VALID_RANKS = ['HIGH_CARD', 'ONE_PAIR', ...]
it { should validate_inclusion_of(:current_rank).in_array(VALID_RANKS) }
```

---

## スパイクテストの活用
- 一時的な実験用コードを用いて動作検証を行う
- 本実装では適切にリファクタリングする

### 例：
```ruby
describe "CLI Interface Spike" do
  it "displays game status correctly", :skip do
    # 実験的なコード
    cli = CLI.new
    output = cli.display_game_status(game)
    puts output  # 実際の出力を確認
    
    # 本実装では、このようなテストは書き直す
  end
end
```
