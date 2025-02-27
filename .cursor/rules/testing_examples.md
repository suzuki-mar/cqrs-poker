# テスト例集

## 基本的なテスト例

### subjectの使い方例
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

## テストファーストの実践例
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

## ActiveRecordモデルのテスト例
```ruby
# 良い例
let(:user) { create(:user) }

# 避けるべき例（例外的なケースを除く）
let(:user) { User.new(name: 'Test User', email: 'test@example.com') }
```

## 振る舞いのテスト例
```ruby
# 避けるべき書き方（実装の詳細に依存）
expect(record).to receive(:save)

# 推奨される書き方（振る舞いの結果を検証）
expect(record.current_turn).to eq(2)
```

## 実装との依存関係の例
```ruby
# 良い例（実装の定数を参照）
it { should validate_inclusion_of(:current_rank).in_array(GameState::VALID_RANKS) }

# 避けるべき例（テスト内で独自に定義）
VALID_RANKS = ['HIGH_CARD', 'ONE_PAIR', ...]
it { should validate_inclusion_of(:current_rank).in_array(VALID_RANKS) }
```

## ドメインオブジェクトのテスト例
```ruby
# GameStateクラスのテスト例
describe '#save_current_state' do
  let(:record) { create(:game_state) }
  let(:game_state) { described_class.new(record) }
  subject { game_state.save_current_state }
  
  it 'レコードの状態が保存される' do
    record.current_turn = 2
    
    subject
    
    saved_record = ::GameState.find(record.id)
    expect(saved_record.current_turn).to eq(2)
  end
end
```

## スパイクテストの活用例
```ruby
# スパイクテストの例（一時的な実験用コード）
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