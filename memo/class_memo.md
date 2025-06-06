# 📘 クラスレイヤーガイド（最終更新日: 2025/06/09）

## このファイルについて
現在のプロジェクトにおける各レイヤーの責務とクラス構成を整理したガイドです。CQRS実装時のディレクトリ配置やクラス設計の参考として使用します。
---

## ✅ Command層（`app/commands`）

### 📌 役割：
ユーザーの入力操作を受け取り、**ゲーム状態を変更する処理**を実行します。

### 主なクラス
- コマンドオブジェクト（`GameStartCommand`, `ExchangeCardCommand`）
- ユースケース実行クラス（`CommandHandler`）
- Aggregateルート

---

## 🔍 Query層（`app/queries`）

### 📌 役割：
発行されたイベントをもとに、**現在のゲーム状態を再構成して取得**する層です。

### 📁 主なクラス
- Projectionクラス（`EventListener::Projection`）
    - イベントを受信してReadModelを更新する処理を担当
- Read Model
    - `PlayerHandState`：プレイヤーの手札状態を管理
    - `TrashState`：捨て札の状態を管理  
    - `Histories`：ゲーム履歴を管理
    - `ProjectionVersions`：Projectionのバージョン管理
- QueryService
    - ゲーム状態の問い合わせに対する統一インターフェース
    - ReadModelからデータを取得し、必要な形式で提供

---

---

## ⚡ Event層（`app/events`）

### 📌 役割：
システム内で発生するイベントの定義と通知システムを管理します。

### 📁 主なクラス
- 各種 Eventクラス
    - `GameStartedEvent`：ゲーム開始時に発行
    - `CardExchangedEvent`：カード交換時に発行
    - `GameEndedEvent`：ゲーム終了時に発行
- EventBus
    - イベントの発行と配信を担当
    - EventPublisherを通じてリスナーにイベントを通知



## ⚙️ シミュレーター層（`app/simulators`）

### 📌 役割：
ゲームのシミュレーション機能を提供します。


### 📁 主なクラス
- Simulator
    - ゲームの自動実行を行うクラス
    - CommandBusを通じてゲーム開始コマンドを発行
    - テストやデモ目的での利用を想定


---

## ⚙️ Model層（`app/domains`）

### 📌 役割：
データの永続化、データの抽象化

### 📁 配置するもの：
- HandSet
    - 手札に関連するもの
- Event
    - イベントソーシングのレコードとして扱っている
- Query
    - ReadModelのために存在するテーブルのDB周り
- 各ID (GameNumber等)
    - `GameNumber`：ゲームを一意に識別するID（5桁のランダム数値）
    - `EventId`：イベントを一意に識別するID
    - 値オブジェクトとして実装され、比較演算子を提供

### ⚠️ ルール：
- CQRS/ESの原則を守るために外部キーは設定しない
- CommandとQueryの両方で使われるクラスのみ配置
- 片方だけで使われるものはそれぞれの層に
- アグリゲートはCommandレイヤーにおく

---



## 🩹 まとめ（責務マップ）

| ディレクトリ | 主な責務 |
|-------------|-----------|
| `commands` | 状態の変更：ユーザー操作を受けてドメインロジックを実行し、イベントを発行する |
| `queries` | 状態の読み取り：イベントを集約してReadModelを構築し、クエリに応答する |
| `events` | イベント管理：ドメインイベントの定義、発行、配信を担当する |
| `simulators` | 自動実行：ゲームの自動化やテスト用のシミュレーション機能を提供する |
| `models` | データ永続化：EventStore、ReadModel、IDクラスなどの永続化層を管理する |


