# 1. GameStart コマンド発行後のAggregateの検証

## 操作(正常系、異常系の両方とも)
* ゲーム開始のコマンドを実行する

## 正常系
### 初回のゲーム開始で Aggregate が存在する状態になること
#### 検証ポイント：
* Aggregateの状態
  * Aggregateが存在すること
    * BoardAggregate.exists_game が true
  * Aggregateがゲーム開始状態になっていること
    * BoardAggregate.game_in_progress が true
    * BoardAggregate.game_ended が false
  * Aggregateの手札の枚数がゲームで指定されたカードの枚数であること
    * BoardAggregate.player_hand.cards.size == GameSetting::MAX_HAND_SIZE
  * AggregateのTrashは作成されているが空のままであること

### 2 回連続で GameStart を呼ぶと、別々のゲーム番号でそれぞれが開始されること
#### 事前操作: 
ゲームスタートのコマンドが実行されている

#### 検証ポイント：
* それぞれのアグリゲートを構築できること
  * アグリゲートストアからゲームナンバーを２つ取得する
  * それぞれのアグリゲートを再構築してgame_in_progress: true であること
