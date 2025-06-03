# ExchangeCard コマンド発行後のAggregateの検証

## すべてのテストで共通

## 事前状態
* ゲームをスタートしていること

## 操作(正常系、異常系の両方とも)
* カード交換のコマンドを実行する

## 正常系
### 初回のゲーム開始で Aggregate が存在する状態になること
#### 検証ポイント：
* Aggregateの状態
  * Aggregateが存在すること
    * BoardAggregate.exists_game が true
  * Aggregateがゲーム開始状態になっていること
    * BoardAggregate.game_in_progress が true
    * BoardAggregate.game_ended が false 
  * AggregateのTrashに捨て札が一枚はいっていること
  * Deckが最初のカードを引いた分 プラス 1枚　へっていること 

### 2 回連続で ExchangeCard を呼ぶ
#### 事前操作: 
カード交換のコマンドを実行する

#### 検証ポイント：
* それぞれのアグリゲートを構築できること
  * それぞれのアグリゲートに応じた交換した手札が作られていること
