require 'rails_helper'

RSpec.describe 'ゲーム終了コマンド後のAggregateの詳細状態' do
  let!(:command_bus) do
    AggregateTestHelper.build_command_bus
  end

  let!(:game_start_result) do
    command_bus.execute(Commands::GameStart.new)
  end

  let!(:game_number) { game_start_result.event.game_number }

  subject do
    command_bus.execute(Commands::EndGame.new(game_number))
  end

  describe '正常系' do
    context 'ゲーム開始後にゲーム終了でAggregateが終了状態になること' do
      it 'Aggregateの状態が正しいこと' do
        board_aggregate = AggregateTestHelper.load_board_aggregate(subject)

        aggregate_failures do
          expect(board_aggregate.exists_game?).to eq(true)
          expect(board_aggregate.game_in_progress?).to eq(false)
          expect(board_aggregate.game_ended?).to eq(true)
        end
      end

      it 'ゲーム終了時にDeckの状態が維持されていること' do
        board_aggregate_before = AggregateTestHelper.load_board_aggregate(game_start_result)
        expected_deck_count = board_aggregate_before.remaining_deck_count

        board_aggregate_after = AggregateTestHelper.load_board_aggregate(subject)

        expect(board_aggregate_after.remaining_deck_count).to eq(expected_deck_count)
      end

      it 'ゲーム終了時にTrashの状態が維持されていること' do
        board_aggregate = AggregateTestHelper.load_board_aggregate(subject)
        expect(board_aggregate.empty_trash?).to eq(true)
      end

      it 'ゲーム終了時に手札が維持されていること' do
        board_aggregate_before = AggregateTestHelper.load_board_aggregate(game_start_result)
        expected_hand_cards = board_aggregate_before.current_hand_cards

        board_aggregate_after = AggregateTestHelper.load_board_aggregate(subject)

        expect(board_aggregate_after.current_hand_cards).to eq(expected_hand_cards)
      end
    end

    context 'カード交換後にゲーム終了する場合' do
      let!(:exchange_result) do
        board_aggregate = AggregateTestHelper.load_board_aggregate(game_start_result)
        discarded_card = board_aggregate.current_hand_cards.first
        command_bus.execute(Commands::ExchangeCard.new(discarded_card, game_number))
      end

      let!(:end_game_after_exchange) do
        exchange_result
        command_bus.execute(Commands::EndGame.new(game_number))
      end

      it 'カード交換後のゲーム終了でAggregateの状態が正しいこと' do
        board_aggregate = AggregateTestHelper.load_board_aggregate(end_game_after_exchange)

        aggregate_failures do
          expect(board_aggregate.exists_game?).to eq(true)
          expect(board_aggregate.game_in_progress?).to eq(false)
          expect(board_aggregate.game_ended?).to eq(true)
        end
      end

      it 'カード交換後のゲーム終了でDeckの枚数が正しいこと' do
        board_aggregate = AggregateTestHelper.load_board_aggregate(end_game_after_exchange)
        # ゲーム開始で5枚引いて、カード交換で1枚引いているので、52 - 6 = 46枚のはず
        expected = GameRule::DECK_FULL_SIZE - (GameRule::MAX_HAND_SIZE + 1)
        expect(board_aggregate.remaining_deck_count).to eq(expected)
      end

      it 'カード交換後のゲーム終了で手札とTrashの状態が正しいこと' do
        board_aggregate = AggregateTestHelper.load_board_aggregate(end_game_after_exchange)

        aggregate_failures do
          expect(board_aggregate.current_hand_cards.size).to eq(GameRule::MAX_HAND_SIZE)
          expect(board_aggregate.empty_trash?).to eq(true)
        end
      end
    end
  end
end
