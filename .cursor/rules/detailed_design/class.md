# クラス設計 最終更新日 2025/03/02

## 1. クラスの概要
このプロジェクトでは、CQRS のシンプルな実装を目指し、以下のようなクラス設計を行う。

### **Game (Entity)**

- `Game` クラスは、ポーカーのゲーム状態を管理するエンティティ。
- `currentRank` によって現在の役（ハンドの強さ）を取得可能。
- 手札 (`hand`) の管理や、カード交換のロジックを提供。

```plaintext
Game
├── currentRank: Rank  # ✅ 現在の手札の役を取得
├── hand: Hand          # ✅ 現在の手札（5枚）
├── giveCard(): Card    # ✅ デッキの一番上のカードを引く
├── receiveExchange(oldCard: Card, newCard: Card)  # ✅ 手札の交換処理
```

---

### **Card (Value Object)**

- `Card` は、スート（♠, ♥, ♦, ♣）とランク（2～10, J, Q, K, A）を持つ。
- `equals()` メソッドでカードの同一性を判定。

```plaintext
Card
├── suit: string  # マーク（♠, ♥, ♦, ♣）
├── rank: string  # 数値または絵札（2〜10, J, Q, K, A）
├── equals(other: Card): bool  # 2枚のカードが同じか判定
├── toString(): string  # ♠A のような文字列形式で出力
```

---

### **Hand (Value Object)**

- `Hand` クラスは、5枚の `Card` を持ち、交換処理を提供。
- `contains()` で特定のカードがあるかをチェック。
- `exchange()` でカードを交換し、新しい `Hand` を作成。

```plaintext
Hand
├── cards: array  # 現在の手札（最大5枚）
├── contains(card: Card): bool  # 指定のカードが手札にあるかを判定
├── exchange(oldCard: Card, newCard: Card): Hand  # 交換処理
├── fromPrevious(previousHand: Hand, newCards: array): Hand  # 新しい手札の作成
```

---

### **Rank (Value Object)**

- `Rank` は、役（ONE PAIR, STRAIGHT, FLUSH など）を表現。
- `determine()` により `Hand` から役を判定。
- `equals()` で同じ役かどうかを比較。

```plaintext
Rank
├── name: string (定数)  # "PAIR", "STRAIGHT", "FLUSH" など
├── determine(hand: Hand): Rank  # 手札から役を判定
├── equals(other: Rank): bool  # 2つの Rank が同じか判定
```

## 2. CQRS の適用

- **コマンド側:** `Game` は状態を変更するロジックを持ち、カード交換やゲームの進行を管理。
- **クエリ側:** `GameState` などのリードモデルがイベントストアを基に現在の状態を再構築。

このクラス設計をもとに、CQRS の原則を明確に適用する。

