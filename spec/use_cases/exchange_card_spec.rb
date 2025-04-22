# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'カード交換をするユースケース' do
  let(:logger) { TestLogger.new }
  let(:command_handler) { UseCaseHelper.build_command_handler(logger) }

  before do
    GameState.destroy_all
    command_handler.handle(Command.new, CommandContext.build_for_game_start)
  end

  let(:read_model) { GameStateReadModel.new }
  let(:current_hand) { GameState.find_current_session.hand_set }
  let(:discarded_card) { Card.new(current_hand.first) }
  let(:context) { CommandContext.build_for_exchange(discarded_card) }

  subject { command_handler.handle(Command.new, CommandContext.build_for_exchange(card)) }

  context '正常系' do
    let(:card) { discarded_card }

    describe '手札のカードを1枚交換できること' do
      let(:original_hand) { read_model.hand_set }

      it 'イベントが正しく発行されること' do
        published_event = subject
        expect(published_event).to be_a(CardExchangedEvent)
        expect(published_event.discarded_card.to_s).to eq(discarded_card.to_s)
        stored_event = EventStore.last
        expect(stored_event.event_type).to eq('card_exchanged')
        expect(stored_event.event_data).to include(discarded_card.to_s)
      end

      it '1回だけ手札を交換しても正しく状態が変化すること' do
        subject
        hand_after = read_model.refreshed_hand_set
        expect(hand_after).not_to include(discarded_card)
        expect(hand_after).not_to eq(original_hand)
      end

      it '2回連続で手札を交換しても正しく状態が変化すること' do
        subject
        hand_after_first = read_model.refreshed_hand_set
        discarded_card2 = hand_after_first.find_by_number(1)
        context2 = CommandContext.build_for_exchange(discarded_card2)
        command_handler.handle(Command.new, context2)
        hand_after_second = read_model.refreshed_hand_set
        expect(hand_after_second).not_to include(discarded_card2)
        expect(hand_after_second).not_to eq(original_hand)
      end

      it 'カード交換時にinfoログが出力されること' do
        subject
        log = logger.messages_for_level(:info).last
        event_store_holder = EventStoreHolder.new
        last_event = event_store_holder.latest_event
        expect(last_event).to be_a(CardExchangedEvent)
        expect(log).to match(/捨てたカード: #{discarded_card}/)
        expect(log).to match(/引いたカード: #{last_event.new_card}/)
      end
    end
  end

  context '異常系' do
    context '手札に存在しないカードを交換した場合' do
      let(:card) { Card.new('♠A') }
      it_behaves_like 'warnログが出力される'
    end

    context '同じカードを2回交換した場合' do
      let(:card) { discarded_card }
      it '2回目でwarnログが出力されること' do
        command_handler.handle(Command.new, CommandContext.build_for_exchange(card)) # 1回目
        command_handler.handle(Command.new, CommandContext.build_for_exchange(card)) # 2回目
        expect(logger.messages_for_level(:warn).last).to match(/不正な選択肢の選択/)
      end
    end

    context 'デッキが空のときに交換した場合' do
      let(:card) { read_model.refreshed_hand_set.cards.first }
      before do
        deck_size = Card::VALID_SUITS.size * Card::VALID_RANKS.size
        hand_size = HandSet::CARDS_IN_HAND
        exchange_count = deck_size - hand_size
        exchange_count.times do
          command_handler.handle(Command.new, CommandContext.build_for_exchange(read_model.refreshed_hand_set.cards.first))
        end
      end
      it_behaves_like 'warnログが出力される'
    end

    xit 'ゲームが終了している状態で交換しようとするとInvalidCommandEventが発行されること' do
      # ゲーム終了状態を作る
      # 交換を試みる
      # InvalidCommandEventになることを検証
    end
  end
end
