# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'カード交換をするユースケース' do
  let(:logger) { TestLogger.new }
  let!(:command_bus) { UseCaseHelper.build_command_bus(logger) }

  before do
    command_bus.execute(Command.new, CommandContext.build_for_game_start)
  end

  let(:read_model) { ReadModels::PlayerHandState.new }
  let(:current_hand) { Query::PlayerHandState.find_current_session.hand_set }
  let(:discarded_card) { HandSet::Card.new(current_hand.first) }
  let(:context) { CommandContext.build_for_exchange(discarded_card) }

  subject { command_bus.execute(Command.new, CommandContext.build_for_exchange(card)) }

  let(:event_publisher) { EventPublisher.new(projection: Projection.new, event_listener: LogEventListener.new(logger)) }
  let(:event_bus) { EventBus.new(event_publisher) }

  context '正常系' do
    let(:card) { discarded_card }

    describe '手札のカードを1枚交換できること' do
      let(:original_hand) { read_model.hand_set }

      it 'イベントが正しく発行されること' do
        current_hand = read_model.refreshed_hand_set
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
        hand_after = read_model.refreshed_hand_set

        expect(hand_after.cards).not_to include(discarded_card)
        expect(hand_after.cards - [discarded_card]).to match_array(original_hand.cards - [discarded_card])
      end

      it '2回連続で手札を交換しても正しく状態が変化すること' do
        subject

        hand_after_first = read_model.refreshed_hand_set
        discarded_card2 = hand_after_first.fetch_by_number(1)
        context2 = CommandContext.build_for_exchange(discarded_card2)
        command_bus.execute(Command.new, context2)

        hand_after_second = read_model.refreshed_hand_set
        expect(hand_after_second.cards).not_to include(discarded_card2)
        expect(hand_after_second.cards - [discarded_card2]).to match_array(original_hand.cards - [discarded_card,
                                                                                                  discarded_card2])
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
      let(:card) { Faker::Hand.not_in_hand_card(read_model.refreshed_hand_set) }
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
      let(:card) { read_model.refreshed_hand_set.cards.first }
      before do
        deck_size = HandSet::Card::VALID_SUITS.size * HandSet::Card::VALID_RANKS.size
        hand_size = GameSetting::MAX_HAND_SIZE
        exchange_count = deck_size - hand_size
        exchange_count.times do
          command_bus.execute(Command.new,
                              CommandContext.build_for_exchange(read_model.refreshed_hand_set.cards.first))
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

  context 'バージョン競合が発生した場合' do
    it '並行実行でバージョン競合が発生し、警告ログが出力されること' do
      command_bus.instance_variable_set(:@exchange_card_handler,
                                        SlowCommandHandler.new(CommandHandlers::ExchangeCard.new(event_bus),
                                                               delay: 0.5))
      card = read_model.refreshed_hand_set.cards.first
      context = CommandContext.build_for_exchange(card)
      results = []
      threads = Array.new(2) do
        Thread.new do
          results << command_bus.execute(Command.new, context)
        end
      end
      threads.each(&:join)

      # 成功と失敗の結果を確認
      success_results = results.select(&:success?)
      error_results = results.select(&:failure?)

      # 1つは成功し、1つは失敗することを確認
      expect(success_results.size).to eq(1)
      expect(error_results.size).to eq(1)

      # 成功した結果はCardExchangedEventであることを確認
      expect(success_results.first.event).to be_a(CardExchangedEvent)

      # 失敗した結果はバージョン競合であることを確認
      expect(error_results.first.error).to be_a(CommandErrors::VersionConflict)

      # 警告ログが出力されることを確認
      expect(logger.messages_for_level(:warn).last).to match(/コマンド失敗: バージョン競合/)
    end
  end
end
