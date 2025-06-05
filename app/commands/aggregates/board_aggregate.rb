# frozen_string_literal: true

# このクラスでは、内部状態を直接外部から変更されないよう、プリミティブ型以外のフィールドをすべて private にしています。
# Aggregate はドメイン不変条件（Invariant）を担保する責務を持つため、外部からコレクションや値オブジェクトを直接操作されると、
# 一貫性チェックやバリデーションを経ずに状態を壊される可能性があります。
#
# そのため、振る舞いを表すメソッド（例：exchange_card、play_card、hand_size など）だけを公開し、
# 必要なデータはイミュータブルなコピーや値オブジェクトで返却することで、一貫性を保ちながら安全にドメインロジックを扱えるように設計しています。

module Aggregates
  class BoardAggregate
    attr_reader :game_number

    def initialize(game_number: nil)
      @deck = Deck.new
      @trash = Trash.new
      @game_started = false
      @game_number = game_number
      @current_hand_set = nil
    end

    def remaining_deck_count
      deck.remaining_count
    end

    def apply(event)
      case event
      when GameStartedEvent
        apply_game_started_event(event)

      when CardExchangedEvent
        apply_card_exchanged_event(event)

      when GameEndedEvent
        apply_game_ended_event(event)
      end
    end

    def drawable?
      deck.remaining_count.positive?
    end

    def current_hand_cards
      return [] unless current_hand_set

      current_hand_set.cards
    end

    def game_in_progress?
      return false if game_number.nil?

      exists_types = Event.exists_by_types(game_number, %w[game_started game_ended])
      exists_types['game_started'] && !exists_types['game_ended']
    end

    def game_ended?
      return false if game_number.nil?

      exists_types = Event.exists_by_types(game_number, %w[game_started game_ended])
      exists_types['game_ended']
    end

    def exists_game?
      return false if game_number.nil?

      Event.exists?(game_number: game_number.value)
    end

    def card_in_deck?(card)
      deck.has?(card)
    end

    # 現時点ではおこなうことはないがAggregateの振る舞いとしてはったほうがいいのでメソッドを実装している
    def finish_game; end

    def empty_trash?
      @trash.cards.empty?
    end

    private

    attr_reader :game_started, :trash, :current_hand_set, :deck

    delegate :draw_initial_hand, :draw, to: :deck

    def apply_game_started_event(event)
      cards = BuildCards.from_started_event(event)
      @game_started = true
      @current_hand_set = HandSet.build(cards)

      remove_from_deck(cards)
    end

    def apply_card_exchanged_event(event)
      new_card = event.to_event_data[:new_card]
      discarded_card = event.to_event_data[:discarded_card]

      current_hand = @current_hand_set
      @current_hand_set = current_hand.rebuild_after_exchange(discarded_card, new_card) if current_hand

      remove_from_deck([new_card])
    end

    def apply_game_ended_event(event)
      # 何もしない
    end

    def remove_from_deck(cards)
      cards.each do |card|
        deck.remove(card) if deck.has?(card)
      end
    end
  end
end
