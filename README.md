# CQRS Poker

ポーカーゲームを題材に、**CQRS（Command Query Responsibility Segregation）パターン**と**イベントソーシング**の基本を学ぶためのサンプルプロジェクトです。

---

## 📚 このプロジェクトの目的
CQRSの「コマンド/クエリ分離」と「イベントソーシングによる状態管理」の本質を、シンプルなコードで体験・理解することを目指します。

---

## 🏗️ 設計思想
- **CQRSの原則をシンプルに体験できること**を最重視
- イベントソーシングによる状態管理を実装
- コマンド/クエリの責務分離を徹底
- 型定義（RBS）を設計書として活用し、実装と設計の同期を重視


## リファレンス
レイヤー間 [class_layer.mdc](.cursor/rules/development/design/class_layer.mdc)
DB設計 [db.mdc](.cursor/rules/development/design/db.mdc)
RBS運営方針 [rbs.mdc](.cursor/rules/development/guidelines/rbs.mdc)