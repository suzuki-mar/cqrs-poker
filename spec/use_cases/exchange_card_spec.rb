# frozen_string_literal: true

require 'rails_helper'
require 'support/use_case_shared'

RSpec.describe 'カード交換をするユースケース' do
  let(:logger) { TestLogger.new }
  let(:command_bus) do
    failure_handler = DummyFailureHandler.new
    CommandBusAssembler.build(
      logger: logger,
      failure_handler: failure_handler
    )
  end
  # load_by_game_number を使用してインスタンスを生成
  let(:player_hand_state) { ReadModels::PlayerHandState.load_by_game_number(game_number) }
  let(:current_hand) { Query::PlayerHandState.find_current_session.hand_set }
  let(:discarded_card) { HandSet::Card.new(current_hand.first) }
  let(:event_bus) do
    event_publisher = EventPublisher.new(projection: EventListener::Projection.new,
                                         event_listener: EventListener::Log.new(logger))
    EventBus.new(event_publisher)
  end

  before do
    Event.destroy_all
  end

  let(:game_number) do
    command_bus.execute(Commands::GameStart.new)
    Aggregates::Store.new.latest_event.game_number
  end

  before do
    ReadModels::ProjectionVersions.load(game_number)
  end

  let(:card) { discarded_card }

  context '正常系' do
    subject { command_bus.execute(Commands::ExchangeCard.new(card, game_number)) }

    let(:original_hand) { player_hand_state.hand_set }

    describe '手札のカードを1枚交換できること' do
      it 'イベントが正しく発行されること' do
        current_hand = player_hand_state.refreshed_hand_set
        discarded_card = current_hand.fetch_by_number(1)

        published_event = command_bus.execute(Commands::ExchangeCard.new(discarded_card, game_number))

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
        # game_number を使用
        command_bus.execute(Commands::ExchangeCard.new(discarded_card2, game_number))

        hand_after_second = player_hand_state.refreshed_hand_set
        expect(hand_after_second.cards).not_to include(discarded_card2)
        expect(hand_after_second.cards - [discarded_card2]).to match_array(original_hand.cards - [discarded_card,
                                                                                                  discarded_card2])
      end

      it '捨て札が正しく更新されていること' do
        subject

        trash_state = ReadModels::TrashState.load(game_number)
        expect(trash_state.number?(discarded_card)).to be true

        # 修正: find_current_sessionではなく、game_numberから直接取得
        player_hand_state_after = ReadModels::PlayerHandState.load_by_game_number(game_number)
        expected_turn = player_hand_state_after.current_turn
        expected_event_id = Aggregates::Store.new.latest_event.event_id

        expect(trash_state.current_turn).to eq(expected_turn)
        expect(trash_state.last_event_id).to eq(expected_event_id)
      end

      it '指定したカードが捨て札に含まれていること' do
        subject

        trash_state = ReadModels::TrashState.load(game_number)

        same_rank_count = trash_state.count_same_rank_by_card(discarded_card)
        expect(same_rank_count).to eq(1)

        same_suit_count = trash_state.count_same_suit_by_card(discarded_card)
        expect(same_suit_count).to eq(1)
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

      context 'バージョン履歴' do
        context 'バージョン履歴が揃っている場合' do
          it 'バージョン履歴をアップデートをしていること' do
            start_event = Aggregates::Store.new.latest_event

            # game_number を使用
            command_bus.execute(Commands::ExchangeCard.new(discarded_card, game_number))
            exchange_event = Aggregates::Store.new.latest_event

            expect(start_event.event_id).to be < exchange_event.event_id

            # game_number を使用
            version_info = ReadModels::ProjectionVersions.load(game_number)
            version_ids = version_info.fetch_all_versions.map(&:last_event_id)
            expect(version_ids).to all(eq(exchange_event.event_id))
          end
        end

        context 'バージョン履歴が揃っていない場合' do
          it 'バージョン履歴をアップデートをしていること' do
            start_event_id = Aggregates::Store.new.latest_event.event_id

            versions = Query::ProjectionVersion.projection_names.keys
            Query::ProjectionVersion.find_or_create_by!(projection_name: versions[0])
                                    .update!(event_id: start_event_id.value)

            subject
            latest_event = Aggregates::Store.new.latest_event

            # CardExchangedEventでは、全バージョンが最新イベントIDに更新される
            version_info = ReadModels::ProjectionVersions.load(game_number)
            version_ids = version_info.fetch_all_versions.map(&:last_event_id)
            expect(version_ids).to all(eq(latest_event.event_id))
          end
        end
      end

      it 'ゲーム終了前はHistoryが作成されていないこと' do
        subject
        expect(Query::History.count).to eq(0)
      end
    end
  end

  context '異常系' do
    context '存在しないGameNumberを指定した場合' do
      subject do
        command_bus.execute(Commands::ExchangeCard.new(
                              HandSet::Card.new('♠A'), GameNumber.build
                            ))
      end
      it_behaves_like 'return command error use_case', :game_not_found
    end

    context '手札に存在しないカードを交換した場合' do
      subject do
        card = CustomFaker.not_in_hand_card(player_hand_state.refreshed_hand_set)
        command_bus.execute(Commands::ExchangeCard.new(card, game_number))
      end
      it_behaves_like 'return command error use_case', :card_not_found
    end

    context '同じカードを2回交換した場合' do
      subject do
        card = discarded_card
        command_bus.execute(Commands::ExchangeCard.new(card, game_number)) # 1回目
        command_bus.execute(Commands::ExchangeCard.new(card, game_number)) # 2回目
      end
      it_behaves_like 'return command error use_case', :card_not_found
    end

    context 'ゲームが終了している状態で交換をする場合', :target do
      before do
        command_bus.execute(Commands::EndGame.new(game_number))
      end

      subject do
        command_bus.execute(Commands::ExchangeCard.new(discarded_card, game_number))
      end

      it_behaves_like 'return command error use_case', :game_already_ended
    end

    context 'デッキが空のときに交換した場合' do
      before do
        deck_size = HandSet::Card::VALID_SUITS.size * HandSet::Card::VALID_NUMBERS.size
        hand_size = GameRule::MAX_HAND_SIZE
        exchange_count = deck_size - hand_size
        exchange_count.times do
          command_bus.execute(Commands::ExchangeCard.new(player_hand_state.refreshed_hand_set.cards.first,
                                                         game_number))
        end
      end
      subject do
        card = player_hand_state.refreshed_hand_set.cards.first
        command_bus.execute(Commands::ExchangeCard.new(card, game_number))
      end
      it_behaves_like 'return command error use_case', :no_cards_left
    end
  end

  it_behaves_like 'version history update examples'
end
