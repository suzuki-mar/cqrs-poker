# テスト概要ガイドライン

## 基本方針
- テストファーストで開発を進める
- 小さなステップで進める
  - 一度に大きな変更を加えない
  - 各ステップで動作確認ができる状態を維持する
- モックの使用を最小限に抑える
  - 原則として実際のオブジェクトを使用する
  - 外部サービスなど、どうしても必要な場合のみモックを使用

## テストの書き方の原則

### シンプルで明確なテスト
- テストコードは可能な限りシンプルに保つ
- 1つのテストは1つの振る舞いだけを検証する
- テスト名は検証する振る舞いを明確に表現する

### コメントの使用
- テストコードは自己説明的であるべき
- 過剰なコメントは避け、コードの可読性を優先する
- 複雑なセットアップが必要な場合のみ、簡潔なコメントを追加する

### テストの構造
- テストは「準備 → 実行 → 検証」の流れで構成する
- 各ステップは明確に分離し、1行空けるなどで視覚的に区別する
- 冗長なコメント（「準備」「実行」「検証」など）は不要

### テストの出力を最小限に
- テストでは不要な出力（puts等）を含めない
- デバッグが必要な場合は一時的な使用に留める
- テスト結果の判定は出力ではなく、アサーションで行う

### 振る舞いに焦点を当てる
- メソッドの呼び出しを検証するのではなく、振る舞いの結果を検証する
- 「何が起きたか」を検証し、「どのように起きたか」には依存しない
- 振る舞いのテストは実装の変更に強く、リファクタリングしても壊れにくい
- モックやスタブは必要な場合のみ使用し、過剰な使用は避ける

### テスト用ダミークラスの定義場所
- テストで使用するダミークラス（モック、スタブなど）は、テストケースの直下に定義する
- メリット：
  - 可読性: テストに関連するすべてのコードが一箇所にまとまる
  - 名前空間の汚染防止: グローバル名前空間を汚染せず、他のテストとの衝突を防ぐ
  - テストの独立性: 各テストが必要なダミークラスを自身で定義するため、テスト間の依存関係が減少
  - メンテナンス性: テストを修正する際に、関連するダミークラスも同時に見直せる
- 例外：
  - 複数のテストで共有する必要があるダミークラスは、`spec/support`ディレクトリに配置
  - 大規模なダミークラスは、可読性のために別ファイルに分離することも検討


## テストデータの作成方針

### FactoryBotの使用
- 原則として`build`を使用し、必要な場合のみ`create`を使用する
  - `build`: DBに保存せずにインスタンスを作成（高速）
  - `create`: DBに保存してインスタンスを作成（低速）
- `create`を使用するケース：
  - 関連オブジェクトの取得が必要な場合
  - DBに依存する機能をテストする場合
  - バリデーションが外部キー制約に依存する場合
- パフォーマンスを意識し、不必要なDB操作を避ける
- テスト実行速度の向上のため、可能な限り`build_stubbed`も検討する

## テストコードの書き方

 **テストの構造を「準備（Arrange）→実行（Act）→検証（Assert）」のパターンに従う**
   - 準備: テスト対象のオブジェクトやモックの設定
   - 実行: テスト対象のメソッドを呼び出す
   - 検証: 期待する結果を確認する
**何をしているのかというコメントは基本的に書かない

 **複雑なテストセットアップには、ヘルパーメソッドやファクトリを使用する**
   - 理由: テストコードの可読性と再利用性が向上する

### 良いテストコードの例

```ruby
RSpec.describe Notification do
  # テスト用のダミークラス
  class DummyEvent    
    def to_h
      { test: 'data' }
    end
    
    def self.name
      'dummy_event'
    end
  end
  
  class DummyHandler
    attr_reader :received_event
    
    def handle(event)
      @received_event = event
    end
  end
  
  describe 'プレイヤー行動通知のテスト' do
    it 'イベントが正しく発行され、ログが出力されること' do
      # 準備（Arrange）
      logger_mock = double('logger')
      allow(Rails).to receive(:logger).and_return(logger_mock)
      expect(logger_mock).to receive(:info).with(/プレイヤー行動ハンドラ登録/).at_least(:once)
      
      handler = DummyHandler.new
      
      # 実行（Act）
      subscription = described_class.register_player_action_handler('dummy_event', handler)
      event = DummyEvent.new
      described_class.notify_player_action(event)
      
      # 検証（Assert）
      expect(handler.received_event).to be_a(DummyEvent)
      
      # クリーンアップ
      ActiveSupport::Notifications.unsubscribe(subscription)
    end
  end
end
```

このテストコードは、コメントがなくても理解しやすく、テストの意図が明確です。必要に応じて「準備→実行→検証」の構造を示すコメントを入れることは許容されますが、各ステップで何をしているかを説明するコメントは避けてください。 



## FactoryBotの適切な使用例
```ruby
# 良い例（DBへの保存が不要な場合）
let(:user) { build(:user) }

# 良い例（関連オブジェクトが必要な場合）
let(:post) { create(:post) }
let(:comment) { build(:comment, post: post) }

# 避けるべき例（不必要なDB保存）
let(:user) { create(:user) } # buildで十分な場合

# パフォーマンス最適化の例
let(:user) { build_stubbed(:user) } # IDも持つがDB保存しない
```

### DBアクセスが必要なケースと不要なケース

```ruby
# DBアクセスが必要なケース
it "ユーザーを検索できる" do
  create(:user, name: "山田太郎")
  create(:user, name: "鈴木次郎")
  
  results = User.search("山田")
  expect(results.count).to eq(1)
  expect(results.first.name).to eq("山田太郎")
end

# DBアクセスが不要なケース
it "フルネームを返す" do
  user = build(:user, first_name: "太郎", last_name: "山田")
  expect(user.full_name).to eq("山田 太郎")
end
``` 
# テスト概要ガイドライン

## 基本方針
- テストファーストで開発を進める
- 小さなステップで進める
  - 一度に大きな変更を加えない
  - 各ステップで動作確認ができる状態を維持する
- モックの使用を最小限に抑える
  - 原則として実際のオブジェクトを使用する
  - 外部サービスなど、どうしても必要な場合のみモックを使用

## テストの書き方の原則

### シンプルで明確なテスト
- テストコードは可能な限りシンプルに保つ
- 1つのテストは1つの振る舞いだけを検証する
- テスト名は検証する振る舞いを明確に表現する

### コメントの使用
- テストコードは自己説明的であるべき
- 過剰なコメントは避け、コードの可読性を優先する
- 複雑なセットアップが必要な場合のみ、簡潔なコメントを追加する

### テストの構造
- テストは「準備 → 実行 → 検証」の流れで構成する
- 各ステップは明確に分離し、1行空けるなどで視覚的に区別する
- 冗長なコメント（「準備」「実行」「検証」など）は不要

### テストの出力を最小限に
- テストでは不要な出力（puts等）を含めない
- デバッグが必要な場合は一時的な使用に留める
- テスト結果の判定は出力ではなく、アサーションで行う

### 振る舞いに焦点を当てる
- メソッドの呼び出しを検証するのではなく、振る舞いの結果を検証する
- 「何が起きたか」を検証し、「どのように起きたか」には依存しない
- 振る舞いのテストは実装の変更に強く、リファクタリングしても壊れにくい
- モックやスタブは必要な場合のみ使用し、過剰な使用は避ける

### `subject` の使い方
- `subject` にはテスト対象のメソッド呼び出しを設定する
- 名前付き `subject` は避け、代わりに `let` でインスタンスを定義する
- テスト内では `subject` を呼び出して実行する

### 例：
```ruby
# 良い例
let(:user) { create(:user) }
subject { user.full_name }

it "returns the full name" do
  expect(subject).to eq("John Doe")
end

# 避けるべき例
subject(:user) { create(:user) }
it "returns the full name" do
  expect(user.full_name).to eq("John Doe")
end
```

### FactoryBotの適切な使用
- 原則として`build`を使用し、必要な場合のみ`create`を使用する
  - `build`: DBに保存せずにインスタンスを作成（高速）
  - `create`: DBに保存してインスタンスを作成（低速）
- `create`を使用するケース：
  - 関連オブジェクトの取得が必要な場合
  - DBに依存する機能をテストする場合
  - バリデーションが外部キー制約に依存する場合
- パフォーマンスを意識し、不必要なDB操作を避ける
- テスト実行速度の向上のため、可能な限り`build_stubbed`も検討する

### テストダブル（モック・スタブ）の使用ガイドライン

#### テスト用ダミークラスの定義場所

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

##### メリット
1. **可読性**: テストに関連するすべてのコードが一箇所にまとまる
2. **名前空間の汚染防止**: グローバル名前空間を汚染せず、他のテストとの衝突を防ぐ
3. **テストの独立性**: 各テストが必要なダミークラスを自身で定義するため、テスト間の依存関係が減少
4. **メンテナンス性**: テストを修正する際に、関連するダミークラスも同時に見直せる

##### 例外
- 複数のテストで共有する必要があるダミークラスは、`spec/support`ディレクトリに配置
- 大規模なダミークラスは、可読性のために別ファイルに分離することも検討

## 新規追加

### テスト記述の言語

- テストケースの記述には日本語を使用することを推奨します。
  - `describe`, `context`, `it` ブロック内の説明は、プロジェクトの可読性を高めるために日本語で記述してください。
  - 例: `it "ユーザーが正しく保存されること" do ... end`

### テストの命名規則

- テストの命名には以下のガイドラインに従ってください：
  - テストの目的が明確に伝わるように具体的な表現を用いる。
  - 動作や期待される結果を具体的に記述する。
  - 例: `it "登録したユーザーの数が正しくカウントされること" do ... end`

### テストの構造とフォーマット

- テストコードは以下の構造に従ってください：
  - **準備（Arrange）**：オブジェクトの生成や設定を行います。
  - **実行（Act）**：テスト対象のメソッドを実行します。
  - **検証（Assert）**：期待する結果をアサートします。
  - 例:
    ```ruby
    it "ユーザーが正しく保存されること" do
      user = build(:user)
      user.save
      expect(user).to be_persisted
    end
    ```


## テストコードの構造化

### 学んだこと
- テストは各カラムごとに`describe`ブロックでグループ化する
- `shoulda-matchers`を使用して簡潔にバリデーションをテストする
- バリデーションテストではエラーメッセージの内容よりも、バリデーションが機能しているかに焦点を当てる

### 実装例
```ruby
RSpec.describe EventStore, type: :model do
  describe 'バリデーション' do
    describe 'event_type' do
      it { should validate_presence_of(:event_type) }
    end

    describe 'event_data' do
      it { should validate_presence_of(:event_data) }
      
      it '不正なJSONの場合はエラーがおきること' do
        event_store = build(:event_store, event_data: 'invalid_json')
        expect(event_store).not_to be_valid
      end
    end
  end
end
```    

## FactoryBotの効果的な使用

### 学んだこと
- テストデータの作成にはFactoryBotを使用する
- 基本的な有効なデータをファクトリで定義し、テストケースごとに必要な属性だけを上書きする

### 実装例
ruby
# ファクトリの定義
FactoryBot.define do
  factory :event_store do
    event_type { 'game_started' }
    event_data { { key: 'value' }.to_json }
    occurred_at { Time.current }
  end
end

#### テストでの使用
event_store = build(:event_store, event_data: 'invalid


## テストの命名と構造

### 学んだこと
- テストの説明は日本語で明確に記述する
- `context`と`it`を使い分けて、テストの意図を明確にする
- テストケースは「〜の場合は〜であること」という形式で記述すると理解しやすい

### 実装例
```ruby
describe 'event_data' do
  it { should validate_presence_of(:event_data) }

  context '無効なJSONの場合' do
    it '有効でないこと' do
      event_store = build(:event_store, event_data: 'invalid_json')
      expect(event_store).not_to be_valid
    end
  end
end
```

## バリデーションエラーのテスト方法

### 学んだこと
- バリデーションテストでは、エラーメッセージの内容よりもバリデーションが機能しているかに焦点を当てる
- `expect(model).not_to be_valid`を使用して、バリデーションが失敗することを確認する
- 特定のエラーメッセージをテストする必要がある場合は、`expect(model.errors[:attribute]).to include("message")`を使用する

### 実装例
```ruby
it '未来の日付の場合はエラーがおきること' do
  event_store = build(:event_store, occurred_at: 1.second.from_now)
  expect(event_store).not_to be_valid
  # エラーメッセージのテストは必要な場合のみ
  # expect(event_store.errors[:occurred_at]).to include("can't be in the future")
end
```