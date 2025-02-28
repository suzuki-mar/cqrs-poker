# 実装ガイドライン

## ディレクトリ構造とファイル配置

### 禁止されるディレクトリ名

以下のディレクトリ名は使用しないでください：

- **services**: 「サービス」という概念は曖昧で、責務が不明確になりがちです。代わりに、より具体的な役割を表す名前を使用してください。
  - 悪い例: `app/services/user_registration_service.rb`
  - 良い例: `app/commands/register_user_command.rb`、`app/queries/find_users_query.rb`

- **helpers**: ヘルパーは責務が不明確になりがちです。代わりに、より具体的な役割を表す名前を使用してください。
  - 悪い例: `app/helpers/date_helper.rb`
  - 良い例: `app/formatters/date_formatter.rb`、`app/validators/date_validator.rb`

- **utils/utilities**: ユーティリティは責務が不明確になりがちです。代わりに、より具体的な役割を表す名前を使用してください。
  - 悪い例: `app/utils/string_utils.rb`
  - 良い例: `app/formatters/string_formatter.rb`、`app/validators/string_validator.rb`

### 推奨されるディレクトリ構造

代わりに、以下のような具体的な役割を表すディレクトリ名を使用してください：

- **commands**: コマンドパターンを実装するクラス（書き込み操作）
  - 例: `app/commands/register_user_command.rb`、`app/commands/update_profile_command.rb`

- **queries**: クエリオブジェクトを実装するクラス（読み取り操作）
  - 例: `app/queries/find_users_query.rb`、`app/queries/get_user_statistics_query.rb`

- **presenters**: プレゼンテーションロジックを実装するクラス
  - 例: `app/presenters/user_presenter.rb`、`app/presenters/product_presenter.rb`

- **formatters**: データフォーマット変換を実装するクラス
  - 例: `app/formatters/date_formatter.rb`、`app/formatters/currency_formatter.rb`

- **validators**: バリデーションロジックを実装するクラス
  - 例: `app/validators/email_validator.rb`、`app/validators/password_validator.rb`

- **policies**: 認可ロジックを実装するクラス
  - 例: `app/policies/user_policy.rb`、`app/policies/article_policy.rb`

- **decorators**: デコレータパターンを実装するクラス
  - 例: `app/decorators/user_decorator.rb`、`app/decorators/product_decorator.rb`

- **adapters**: アダプタパターンを実装するクラス（外部サービスとの連携）
  - 例: `app/adapters/payment_gateway_adapter.rb`、`app/adapters/email_service_adapter.rb`

- **factories**: ファクトリパターンを実装するクラス
  - 例: `app/factories/report_factory.rb`、`app/factories/notification_factory.rb`

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

### 具体的な実践方法

#### ドキュメント管理
- ディレクトリ構造を自己説明的にする
  - 例: `.cursor/rules/testing/` 配下にテスト関連のドキュメントを配置
- ファイル名で内容を明確にする
  - 例: `overview.md`, `practices.md`, `examples.md`
- READMEなどの目次ファイルは作成しない
  - 理由: ファイル変更のたびに更新が必要になり、管理コストが高い
  - 代わりに: ディレクトリ構造とファイル名で内容を表現する

#### コード管理
- 定数や設定値は一箇所で定義
  - 例: `VALID_RANKS = ['HIGH_CARD', 'ONE_PAIR', ...]` はモデルに定義し、テストからは参照する
- 共通ロジックはヘルパーやサービスに抽出
  - 例: 複数のコントローラで使用する認証ロジックは `AuthenticationService` に抽出
- 重複するテストデータはファクトリに定義
  - 例: `FactoryBot.define { factory :user do ... end }`

#### API仕様
- OpenAPI/Swaggerなどを使用して一元管理
- コードからAPI仕様を自動生成する仕組みを導入
- 手動でAPI仕様書を更新しない

#### データベーススキーマ
- マイグレーションファイルを正として扱う
- `schema.rb` は自動生成されるものとして扱い、直接編集しない
- ERDは必要に応じて `schema.rb` から自動生成

### 二重管理が許容されるケース
- パフォーマンス上の理由がある場合
  - 例: キャッシュとしてのデータの複製
- システム間の連携で避けられない場合
  - 例: 外部システムとのデータ同期
- 明確な責任分担がある場合
  - 例: フロントエンドとバックエンドでの型定義

### 二重管理を発見した場合の対応
1. 情報の正しい「正」を特定する
2. 他の場所での定義を参照に変更する
3. 自動化できる部分は自動化する
4. やむを得ず二重管理する場合は、その理由をコメントで明記する 