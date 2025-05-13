# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'カード交換をするユースケース' do
  let(:logger) { TestLogger.new }
  # コマンドバスの初期化による副作用や前提状態のセットアップを、テスト実行前に必ず行いたい
  let!(:command_bus) { UseCaseHelper.build_command_bus(logger) }
  let(:player_hand_state) { ReadModels::PlayerHandState.new }
  let(:current_hand) { Query::PlayerHandState.find_current_session.hand_set }
  let(:discarded_card) { HandSet::Card.new(current_hand.first) }
  let(:context) { CommandContext.build_for_exchange(discarded_card) }
  let(:event_bus) do
    event_publisher = EventPublisher.new(projection: Projection.new, event_listener: LogEventListener.new(logger))
    EventBus.new(event_publisher)
  end

  before do
    command_bus.execute(Command.new, CommandContext.build_for_game_start)
  end

  subject { command_bus.execute(Command.new, CommandContext.build_for_exchange(card)) }

  context '正常系' do
    let(:card) { discarded_card }

    describe '手札のカードを1枚交換できること' do
      let(:original_hand) { player_hand_state.hand_set }

      it 'イベントが正しく発行されること' do
        current_hand = player_hand_state.refreshed_hand_set
        discarded_card = current_hand.fetch_by_number(1)
        context = CommandContext.build_for_exchange(discarded_card)
        published_event = command_bus.execute(Command.new, context)

        expect(published_event.event).to be_a(CardExchangedEvent)
        expect(published_event.event.to_event_data[:discarded_card].to_s).to eq(discarded_card.to_s)

        stored_event = Aggregates::Store.new.latest_event
        expect(stored_event.event_type).to eq(CardExchangedEvent.event_type)
        expect(stored_event.to_event_data[:discarded_card].to_s).to eq(discarded_card.to_s)
      end

      it '1回だけ手札を交換しても正しく状態が変化すること' do
        subject
        hand_after = player_hand_state.refreshed_hand_set

        expect(hand_after.cards).not_to include(discarded_card)
        expect(hand_after.cards - [discarded_card]).to match_array(original_hand.cards - [discarded_card])
      end

      it '2回連続で手札を交換しても正しく状態が変化すること' do
        subject

        hand_after_first = player_hand_state.refreshed_hand_set
        discarded_card2 = hand_after_first.fetch_by_number(1)
        context2 = CommandContext.build_for_exchange(discarded_card2)
        command_bus.execute(Command.new, context2)

        hand_after_second = player_hand_state.refreshed_hand_set
        expect(hand_after_second.cards).not_to include(discarded_card2)
        expect(hand_after_second.cards - [discarded_card2]).to match_array(original_hand.cards - [discarded_card,
                                                                                                  discarded_card2])
      end

      it '捨て札が正しく更新されていること' do
        subject

        trash_state = ReadModels::TrashState.load
        expect(trash_state.number?(discarded_card)).to be true

        expected_turn = Query::PlayerHandState.find_current_session.current_turn
        expected_event_id = Aggregates::Store.new.latest_event.event_id

        expect(trash_state.current_turn).to eq(expected_turn)
        expect(trash_state.last_event_id).to eq(expected_event_id)
      end

      it 'カード交換時にinfoログが出力されること' do
        subject

        log = logger.messages_for_level(:info).last
        event_store_holder = Aggregates::Store.new
        last_event = event_store_holder.latest_event

        expect(last_event).to be_a(CardExchangedEvent)
        expect(log).to match(/捨てたカード: #{discarded_card}/)
        expect(log).to match(/引いたカード: #{last_event.to_event_data[:new_card]}/)
      end

      it 'ゲーム終了前はHistoryが作成されていないこと' do
        subject
        expect(Query::History.count).to eq(0)
      end
    end
  end

  context '異常系' do
    context '手札に存在しないカードを交換した場合' do
      let(:card) { CustomFaker.not_in_hand_card(player_hand_state.refreshed_hand_set) }
      it '警告ログが正しく出力されること' do
        subject
        expect(logger.messages_for_level(:warn).last).to match(/コマンド失敗: 交換対象のカードが手札に存在しません/)
      end
    end

    context '同じカードを2回交換した場合' do
      let(:card) { discarded_card }
      it '2回目で警告ログが正しく出力されること' do
        command_bus.execute(Command.new, CommandContext.build_for_exchange(card)) # 1回目
        command_bus.execute(Command.new, CommandContext.build_for_exchange(card)) # 2回目
        expect(logger.messages_for_level(:warn).last).to match(/コマンド失敗: 交換対象のカードが手札に存在しません/)
      end
    end

    context 'デッキが空のときに交換した場合' do
      let(:card) { player_hand_state.refreshed_hand_set.cards.first }
      before do
        # デッキが空の状態を事前に作るためのセットアップ
        # これにより、「デッキが空のときに交換しようとした場合のエラーやログ出力をテストする
        deck_size = HandSet::Card::VALID_SUITS.size * HandSet::Card::VALID_NUMBERS.size
        hand_size = GameSetting::MAX_HAND_SIZE
        exchange_count = deck_size - hand_size
        exchange_count.times do
          command_bus.execute(Command.new,
                              CommandContext.build_for_exchange(player_hand_state.refreshed_hand_set.cards.first))
        end
      end
      it '警告ログが正しく出力されること' do
        subject
        expect(logger.messages_for_level(:warn).last).to match(/コマンド失敗: デッキの残り枚数が不足しています/)
      end
    end

    it 'ゲームが終了している状態で交換しようとするとInvalidCommandが発行されること' do
      command_bus.execute(Command.new, CommandContext.build_for_end_game)

      result = command_bus.execute(Command.new, CommandContext.build_for_exchange(discarded_card))

      expect(result.error).to be_a(CommandErrors::InvalidCommand)
      expect(result.error.reason).to eq('ゲームが進行中ではありません')
    end
  end

  # バージョン競合が発生した場合は version_conflict_specでテストをしている
end
