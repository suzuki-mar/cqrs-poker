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