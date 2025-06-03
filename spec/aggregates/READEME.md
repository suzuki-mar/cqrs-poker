## はじめに

このディレクトリ (spec/aggregates/) に配置されているテストは、
UseCase 層のテスト（spec/use_cases/ 配下の統合テスト）や、
Commands/CommandHandler 層のユニットテスト（spec/commands/ 配下）とは明確に独立しています。


## テストの責務を分離するため
Commands/CommandHandler のユニットテスト (spec/commands/) は、
「個々のコマンドハンドラが正しい CommandResult を返すか」や、「
不正なパラメタでエラーが返るか」などを確認します。

UseCase（ユースケース）テスト (spec/use_cases/) は、
コマンドバスを経由して実際のフロー全体（コマンド発行 → CommandHandler → Aggregate → Projection → ReadModel）を検証し、
システム全体が期待どおり連携して動作するかを確認します。

一方で、Aggregate 層のテスト (spec/aggregates/) は、あくまで「コマンド発行後に生成されたイベントを Aggregate 自身が正しく受け取り、
内部状態（手札・捨て札・ゲーム状態など）が正しく遷移するか」を直接検証します。

つまり、Commands/CommandHandler は「イベントを作る」、Aggregate は「イベントを適用して自分の状態を更新する」、
UseCase テスト は「全体が繋がっているか」をそれぞれ担保するという役割分担になっており、相互に依存させずに個別にテストできるようにしています。


## ドメインロジックの確実な検証

Aggregate 層では「ビジネスルールそのもの（たとえば手札交換のルールやゲーム終了の条件など）」を扱うため、
外側のフレームワークやインフラ（CommandBus や Projection／ReadModel）に影響されないかたちで、純粋な状態遷移を検証する必要があります。

もし UseCase テストや CommandHandler テストと混在させると、テストの失敗原因が「CommandHandler のバリデーションか 
Aggregate のビジネスロジックか Projection の更新漏れか」がわかりにくくなるため、
Aggregate 自身の「イベント適用 → 内部状態更新」を切り出してテストできるように分離しています。

## メンテナンス性と可読性の向上

それぞれのレイヤーに対応したテストを専用ディレクトリに分けておくことで、
将来的にドメインルールを追加・変更するときは spec/aggregates/ を、 全体フローを確認するときは spec/use_cases/ を見るだけで済みます。
また、クラス単体のユニットテストを書くときは通常のRspecのルールに従ってファイルを作成します。

これにより「エラーが出たらまずどのテストを見るべきか」が明確になり、開発者が迷わずテストを修正・追加できるようになります。