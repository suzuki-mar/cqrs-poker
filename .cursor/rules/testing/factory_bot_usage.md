# FactoryBotの使用方法

## 基本方針
- 原則として`build`を使用し、必要な場合のみ`create`を使用する
  - `build`: DBに保存せずにインスタンスを作成（高速）
  - `create`: DBに保存してインスタンスを作成（低速）
  - `build_stubbed`: IDも持つがDB保存しない（最も高速）
- テスト実行速度を意識し、不必要なDB操作を避ける

## 適切な使用例

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

## `create`を使用するケース
- 関連オブジェクトの取得が必要な場合
- DBに依存する機能をテストする場合
- バリデーションが外部キー制約に依存する場合
- ActiveRecordのコールバックの動作確認が必要な場合

## `build`を使用するケース
- モデルのインスタンスメソッドのテスト
- バリデーションのテスト（DB制約に依存しないもの）
- フォームオブジェクトのテスト
- 値の計算や整形のテスト

## `build_stubbed`を使用するケース
- 関連付けのテスト（実際のDBアクセスが不要な場合）
- パフォーマンスが特に重要な場合
- IDが必要だが、実際のDBレコードは不要な場合

## DBアクセスが必要なケースと不要なケース

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

## ファクトリの定義のベストプラクティス

```ruby
# 基本的なファクトリ定義
FactoryBot.define do
  factory :user do
    first_name { "太郎" }
    last_name { "山田" }
    email { "taro.yamada@example.com" }
    
    # 動的な値の生成
    sequence(:username) { |n| "user#{n}" }
    
    # Fakerの活用
    address { Faker::Address.street_address }
    
    # トレイトの定義
    trait :admin do
      admin { true }
    end
    
    # ネストしたファクトリ
    factory :admin_user do
      admin { true }
    end
  end
end
``` 