READMEを、初めてこのプロジェクトに触れる人が「何をするものか」「どうやって動かすか」「どんな設計思想か」がすぐ分かるように、以下のようにアップデートする提案です。

---

```markdown:README.md
# CQRS Poker

ポーカーゲームを題材に、**CQRS（Command Query Responsibility Segregation）パターン**と**イベントソーシング**の基本を学ぶためのサンプルプロジェクトです。

---

## 📚 このプロジェクトについて

- **目的**  
  複雑な業務ロジックや本格的なポーカー実装ではなく、  
  CQRSの「コマンド/クエリ分離」と「イベントソーシングによる状態管理」の本質を、  
  シンプルなコードで体験・理解することを目指します。

- **特徴**
  - 状態の変更は「イベント」として記録し、そこから現在の状態を再構築します
  - 書き込み（コマンド）と読み込み（クエリ）の責務を明確に分離しています
  - 最小限のコマンド（`StartGame`、`ExchangeCard`、`EndGame`）のみを実装
  - 読み取りモデルはイベントストアから再構築されます

---

## 🚀 はじめかた

### 1. 必要なもの

- Ruby（バージョンは `.ruby-version` またはGemfile参照）
- Bundler

### 2. セットアップ

```sh
git clone https://github.com/yourname/cqrs-poker.git
cd cqrs-poker
bundle install
```

### 3. テストの実行

```sh
bundle exec rspec
```

- テストは「日本語」で意図が明確に書かれています
- 失敗した場合はエラーメッセージをよく確認してください

### 4. サンプル実行（任意）

- 実際のコマンドやイベントの流れを試したい場合は、`bin/console` でIRBを起動し、  
  ドメインクラスを直接操作できます。

---

## 🏗️ 設計思想

- **CQRSの原則をシンプルに体験できること**を最重視
- イベントソーシングによる状態管理を実装
- コマンド/クエリの責務分離を徹底
- 型定義（RBS）を設計書として活用し、実装と設計の同期を重視

---

## 📝 参考

- [CQRSパターンとは？（外部リンク）](https://martinfowler.com/bliki/CQRS.html)
- [イベントソーシングとは？（外部リンク）](https://martinfowler.com/eaaDev/EventSourcing.html)

---

## 💬 サポート

- 質問・Issue・PR歓迎です！
- コードや設計に関する疑問は、[Issues](https://github.com/yourname/cqrs-poker/issues) へどうぞ

```

---

この内容でREADMEを更新してもよろしいでしょうか？  
（ご要望があれば、プロジェクトのURLやRubyバージョンなども追記できます）
