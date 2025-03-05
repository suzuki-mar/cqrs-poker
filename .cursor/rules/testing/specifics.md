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

## バリデーションテストの実装方針

バリデーションテストでは、主にモデルが適切にバリデーションを行っているかどうかを確認します。以下の点に注意してください：

- バリデーションテストでは、エラーメッセージの内容をチェックするのではなく、モデルのインスタンスが有効か無効かのみを検証します。
- `expect(model).not_to be_valid` や `expect(model).to be_invalid` を使用して、バリデーションが正しく機能しているかを確認します。
- エラーメッセージの具体的な内容は、テストの対象から外します。これにより、エラーメッセージの文言が変更された場合でもテストが失敗することはありません。

### 例：
```ruby
describe "event_type" do
  it 'nilの場合は無効であること' do
    event_store = build(:event_store, event_type: nil)
    expect(event_store).not_to be_valid
  end
end
```

この方針により、テストはより堅牢になり、実装の変更に強くなります。また、テストのメンテナンスが容易になります。

## `shoulda-matchers` の使用方針

`shoulda-matchers` は、Railsアプリケーションのテストをより簡潔に、かつ表現力豊かに書くためのライブラリです。特にモデルのバリデーション、アソシエーション、データベースのカラムのテストに有効です。

- `shoulda-matchers` を使用することで、一行で明確かつ簡潔にバリデーションのテストを記述できます。
- モデルが期待通りのバリデーションを持っているか、正しくアソシエーションが設定されているかをテストするのに適しています。

### 例：
```ruby
describe User do
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should have_many(:posts) }
end
```

このライブラリを使用することで、テストコードの量を減らし、読みやすく、保守しやすいテストを書くことができます。プロジェクトのテスト戦略に`shoulda-matchers`を組み込むことを検討してください。
