require 'rails_helper'

RSpec.describe 'カード交換コマンド後のAggregateの詳細状態' do
  let!(:command_bus) do
    failure_handler = DummyFailureHandler.new
    CommandBusAssembler.build(failure_handler: failure_handler)
  end

  let(:aggregate_store) { Aggregates::Store.new }
  let(:game_started_result) { command_bus.execute(Commands::GameStart.new) }
  let(:game_number) { game_started_result.event.game_number }
  let(:board_aggregate) { AggregateTestHelper.load_board_aggregate(game_started_result) }

  subject do
    discarded_card = board_aggregate.current_hand_cards.first
    command_bus.execute(Commands::ExchangeCard.new(discarded_card, game_number))
  end

  describe '正常系' do
    context '初回のゲーム開始時でAggregateが存在する状態になること' do
      it 'ゲームが開始する状態Aggregateの状態が正しいこと' do
        board_aggregate = AggregateTestHelper.load_board_aggregate(subject)

        aggregate_failures do
          expect(board_aggregate.exists_game?).to eq(true)
          expect(board_aggregate.game_in_progress?).to eq(true)
          expect(board_aggregate.game_ended?).to eq(false)
        end
      end

      it 'AggregateのTrashの状態を確認する' do
        board_aggregate = AggregateTestHelper.load_board_aggregate(subject)
        expect(board_aggregate.empty_trash?).to eq(false)
      end

      it 'Deckが最初のカードを引いた分プラス1枚減っていること' do
        board_aggregate = AggregateTestHelper.load_board_aggregate(subject)
        expected = GameRule::DECK_FULL_SIZE - (GameRule::MAX_HAND_SIZE + 1)
        expect(board_aggregate.remaining_deck_count).to eq(expected)
      end
    end

    context '2回連続でExchangeCardを呼ぶ' do
      let(:first_exchange_result) { subject }

      let(:second_exchange_result) do
        board_aggregate = AggregateTestHelper.load_board_aggregate(first_exchange_result)
        second_discarded_card = board_aggregate.current_hand_cards.first
        command_bus.execute(Commands::ExchangeCard.new(second_discarded_card, game_number))
      end

      it 'それぞれのアグリゲートを構築できること' do
        first_aggregate = AggregateTestHelper.load_board_aggregate(first_exchange_result)
        second_aggregate = AggregateTestHelper.load_board_aggregate(second_exchange_result)

        aggregate_failures do
          expect(first_aggregate.game_number).to eq(second_aggregate.game_number)
          expect(second_aggregate.remaining_deck_count).to eq(first_aggregate.remaining_deck_count - 1)
          expect(first_aggregate.empty_trash?).to eq(false)
          expect(second_aggregate.empty_trash?).to eq(false)
        end
      end

      it 'それぞれのアグリゲートに応じた交換した手札が作られていること' do
        first_aggregate = AggregateTestHelper.load_board_aggregate(first_exchange_result)
        second_aggregate = AggregateTestHelper.load_board_aggregate(second_exchange_result)

        aggregate_failures do
          expect(first_aggregate.current_hand_cards.size).to eq(GameRule::MAX_HAND_SIZE)
          expect(second_aggregate.current_hand_cards.size).to eq(GameRule::MAX_HAND_SIZE)
          expect(first_aggregate.current_hand_cards).not_to eq(second_aggregate.current_hand_cards)
        end
      end
    end
  end
end
