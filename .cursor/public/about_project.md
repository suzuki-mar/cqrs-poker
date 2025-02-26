# CQRS Poker

## 1. このプロジェクトの目的

このプロジェクトはゲームを作ることが目的ではない。

### このプロジェクトで何を実現したいのか？

CQRS（Command Query Responsibility Segregation）をシンプルな形で実装することで、その基本的な動作を理解することを目的とする。特に、以下の点に焦点を当てる：

#### イベントソーシングを利用した状態管理
- 状態の変化を直接保存するのではなく、イベントとして記録し、それを基に現在の状態を構築する。

#### コマンドとクエリの分離
- 書き込み（コマンド）と読み取り（クエリ）の責務を明確に分離し、システムの拡張性を確保する。

### このプロジェクトの最も大事な特徴は何か？

このプロジェクトは、CQRS の原則をシンプルな形で適用することに重点を置く。そのため、余計な機能や複雑なビジネスルールは排除し、以下の要素に集中する：

#### 最小限のコマンドとイベント
- StartGame, ExchangeCard, EndGame の3つのコマンドのみを用意し、シンプルな状態変化の流れを表現。

#### シンプルなリードモデルの構築
- EventStore から状態を再構築する仕組みを組み込み、CQRS の「読み取りの独立性」を明示する。

### このプロジェクトがどんな人に役立つのか？

#### 自分が CQRS を理解するため
- 実装を通じて、イベントソーシングや CQRS の基本的な概念を体験的に学ぶ。
- 実際にコードを書きながら、イベントの流れやリードモデルの再構築を確認できる。

#### 他の人に CQRS の考え方を伝えるため
- シンプルなCQRSの例として、他の開発者が学習しやすい構成になっている。
- 余計な機能を削ぎ落とし、CQRSの本質に集中できる設計にすることで、初心者でも理解しやすくする。

## 2. コマンド & イベント設計

### 📖 コマンド一覧

| コマンド名 | 引数 | 説明 |
|------------|------|------|
| StartGame() | なし | ゲームを開始する（イベントの登録のみ） |
| ExchangeCard(oldCard: Card) | oldCard: 交換するカード | 好きなだけ交換できる（1回の実行につき1枚のみ） |
| EndGame() | なし | ゲームを終了する（イベントの登録のみ） |

### 📂 イベント一覧

| イベント名 | event_data のキー | 型 | 説明 |
|------------|------------------|-----|------|
| GameStarted | なし | なし | ゲーム開始時のイベントのみ記録 |
| CardExchanged | oldCard | Card | 交換前のカード（手札内にあることが必須） |
| | newCard | Card | 交換後のカード（デッキの次の1枚） |
| GameEnded | なし | なし | ゲームが終了したことを記録 |

## 3. クラス設計

### Game (Entity)

Game
├── currentRank: Rank  # ✅ 現在の手札の役を取得
Game ├── hand: Hand               # ✅ 現在の手札（5枚） ├── giveCard(): Card         # ✅ デッキの一番上のカードを引く ├── receiveExchange(oldCard: Card, newCard: Card)  # ✅ 手札内の oldCard を newCard に交換

Card (Value Object)

Card ├── suit: string  # マーク（♠, ♥, ♦, ♣） ├── rank: string  # 数値または絵札（2〜10, J, Q, K, A） ├── equals(other: Card): bool  # 2枚のカードが同じか判定 ├── toString(): string  # ♠A のような文字列形式で出力

Hand (Value Object)

Hand ├── cards: array  # 現在の手札（最大5枚） ├── contains(card: Card): bool  # 指定のカードが手札にあるかを判定 ├── exchange(oldCard: Card, newCard: Card): Hand  # 指定したカードを新しいカードに交換（新しい Hand を返す） ├── fromPrevious(previousHand: Hand, newCards: array): Hand  # 既存の手札と新しい手札を組み合わせて新しい Hand を作成

Rank (Value Object)

Rank ├── name: string (定数)  # "PAIR", "STRAIGHT", "FLUSH" など ├── determine(hand: Hand): Rank  # 手札から役を判定 ├── equals(other: Rank): bool  # 2つの Rank が同じか判定

## 4. テーブル設計


### EventStore（イベントストア）

| カラム名 | 型 | 説明 |
|----------|-------|------|
| id | BIGSERIAL | 主キー、自動採番 |
| event_type | TEXT | イベントの種類 (GameStarted, CardExchanged, GameEnded など) |
| event_data | JSONB | イベントの詳細データ |
| occurred_at | TIMESTAMP | イベントが発生した時間 |

### GameState（リードモデル）

GameState には id を設けていない。これは GameState がリードモデルであり、過去の状態を保持する必要がないためである。リードモデルは常に最新の情報を反映するため、プライマリキーとしての id を持たなくても一意にデータを管理できる。

ポーカーは手札が5枚というのが大前提なため、hand_1 〜 hand_5 のカラムの方が良い。

📌 そのメリット：

1. データの一貫性を保証できる
   - 5枚の手札を必ず持つというルールをDBレベルで保証できる
   - NULL や可変長リストの管理を考える必要がなくなる

2. SQL のクエリがシンプルになる
   - SELECT hand_1, hand_2, hand_3, hand_4, hand_5 FROM GameState で直接手札を取得できる
   - JSONB だと配列をパースする必要があるが、個別カラムならクエリだけで処理できる

3. パフォーマンスの向上
   - JSONB よりもカラムアクセスのほうが一般的に高速
   - インデックスを活用しやすく、データアクセスの最適化が可能

## 5. ターミナルの表示形式

1️⃣ ゲーム開始時

=========================
🎮 ポーカーゲーム開始 🎮
=========================
[ターン: 1]
🃏 初期手札: ♠A ♦K ♥5 ♣7 ♠9
-------------------------
コマンドを選択してください:
[1] 交換する
[2] ゲーム終了
=========================

2️⃣ カード交換時

=========================
[ターン: 1]
🃏 交換: ♥5 → ♠J
🃏 新しい手札: ♠A ♦K ♠J ♣7 ♠9
-------------------------
コマンドを選択してください:
[1] 交換する
[2] ゲーム終了
=========================

3️⃣ 次のターン進行

=========================
[ターン: 2]
🃏 現在の手札: ♠A ♦K ♠J ♣7 ♠9
-------------------------
コマンドを選択してください:
[1] 交換する
[2] ゲーム終了
=========================

4️⃣ ゲーム終了時

=========================
🎮 ゲーム終了 🎮
=========================
[最終ターン: 3]
🃏 最終手札: ♠A ♦K ♠J ♣7 ♠9
🎖 役: ONE PAIR
=========================

## 6. 実行方法

前提条件

Ruby on Rails がインストールされていること

必要な gem がインストール済み (bundle install でインストール)

ゲームの開始

以下のコマンドを実行すると、ゲームが開始されます。

bin/rake start

このコマンドを実行すると、ターミナルにゲームの状態が表示され、ユーザーがコマンドを入力できるようになります。

