
# 実装ガイドライン

## ディレクトリ構造とファイル配置

### 禁止されるディレクトリ名

以下のディレクトリ名は使用しないでください：

- **services**: 「サービス」という概念は曖昧で、責務が不明確になりがちです。代わりに、より具体的な役割を表す名前を使用してください。
  - 悪い例: `app/services/user_registration_service.rb`
  - 良い例: `app/commands/register_user_command.rb`

- **helpers**: ヘルパーは責務が不明確になりがちです。代わりに、より具体的な役割を表す名前を使用してください。
  - 悪い例: `app/helpers/date_helper.rb`
  - 良い例: `app/formatters/date_formatter.rb`

- **utils/utilities**: ユーティリティは責務が不明確になりがちです。代わりに、より具体的な役割を表す名前を使用してください。
  - 悪い例: `app/utils/string_utils.rb`
- 良い例: `app/formatters/string_formatter.rb`、

### 理由

「サービス」や「ヘルパー」、「ユーティリティ」といった名前は、具体的な責務を表していません。これらのディレクトリには、様々な責務を持つクラスが混在しがちです。

より具体的な役割を表す名前を使用することで、以下のメリットがあります：

1. **責務の明確化**: クラスの役割が名前から明確になります
2. **コードの発見可能性**: 必要なコードを見つけやすくなります
3. **設計の一貫性**: アプリケーション全体で一貫した設計原則が適用されます
4. **新しいコードの配置**: 新しいコードをどこに配置すべきかが明確になります

## 二重管理の回避

### 原則
- 同じ情報を複数の場所で管理することを避ける
- 情報は一箇所で定義し、必要に応じて参照する
- ドキュメントとコードの整合性を保つため、自動生成を活用する

#### コード管理
- 定数や設定値は一箇所で定義
  - 例: `VALID_RANKS = ['HIGH_CARD', 'ONE_PAIR', ...]` はモデルに定義し、テストからは参照する
- 共通ロジックはヘルパーやサービスに抽出
  - 例: 複数のコントローラで使用する認証ロジックは `AuthenticationService` に抽出
- 重複するテストデータはファクトリに定義
  - 例: `FactoryBot.define { factory :user do ... end }`

### 二重管理を発見した場合の対応
1. 情報の正しい「正」を特定する
2. 他の場所での定義を参照に変更する
3. 自動化できる部分は自動化する
4. やむを得ず二重管理する場合は、その理由をコメントで明記する 

## コメントスタイル

### 翻訳コメントはしない（コードをそのまま日本語で説明するようなコメント）
良いコメントの例は、Why?（なぜそのような実装をしたのか）や、コードを読んだだけではわからない意図を書くことです。

#### 良いコメントの例
```
# AWS SNSは高い可用性と拡張性を提供するため選択された。
def send_notification(user, message)
  return unless user.prefers_notifications?
  AwsSnsService.deliver(user, message)
end
```

#### 悪いコメントの例
```
# 通知を送信する
def send_notification(user, message)
  return unless user.prefers_notifications?
  AwsSnsService.deliver(user, message)
end
```

## エラーハンドリングの適切な実装

### 学んだこと
- nil値のチェックを忘れずに行う
  - 特にJSONのパースなど、特定の型を期待する処理の前には必ずnilチェックを行う
  - 例: return false if json.nil?
- 例外が発生する可能性のある処理は適切に捕捉する
  - 例: rescue JSON::ParserError

### 実装例
ruby
def valid_json?(json)
  return false if json.nil?  # nilチェックを忘れない
  JSON.parse(json)
  true
rescue JSON::ParserError
  false
end

## コマンドパターンの実装

### 学んだこと
- コマンドクラスは単一責任の原則に従って設計する
- 初期化時に必要な依存関係を注入し、実行時のパラメータは最小限に抑える
- `execute`メソッドを公開インターフェースとして提供する

### 実装例
```ruby
class GameStartCommand
  def initialize(event_store)
    @event_store = event_store
  end

  def execute
    @event_store.publish("game_started")
  end
end
```