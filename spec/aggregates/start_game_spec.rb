require 'rails_helper'

RSpec.describe 'ゲーム開始コマンド後のAggregateの詳細状態' do
  let!(:command_bus) do
    failure_handler = DummyFailureHandler.new
    CommandBusAssembler.build(failure_handler: failure_handler)
  end

  let!(:aggregate_store) { Aggregates::Store.new }

  subject { command_bus.execute(Commands::GameStart.new) }

  describe '正常系' do
    context '初回のゲーム開始でAggregateが存在する状態になること' do
      it 'Aggregateの状態が正しいこと' do
        board_aggregate = AggregateTestHelper.load_board_aggregate(subject)

        aggregate_failures do
          expect(board_aggregate.exists_game?).to eq(true)
          expect(board_aggregate.game_in_progress?).to eq(true)
          expect(board_aggregate.game_ended?).to eq(false)
        end
      end

      it '手札に存在するカードが山札にないこと' do
        board_aggregate = AggregateTestHelper.load_board_aggregate(subject)

        aggregate_failures do
          board_aggregate.current_hand_cards.each do |card|
            expect(board_aggregate.card_in_deck?(card)).to eq(false), "手札のカード #{card} が山札に残っています"
          end
        end
      end

      it '初期状態に引いて手札にしたカードがデッキからなくなっていること' do
        board_aggregate = AggregateTestHelper.load_board_aggregate(subject)
        # 手札が5枚引かれているので、52 - 5 = 47枚残っているはず
        expect(board_aggregate.remaining_deck_count).to eq(47)
      end

      it 'AggregateのTrashは作成されているが空のままであること' do
        board_aggregate = AggregateTestHelper.load_board_aggregate(subject)
        expect(board_aggregate.empty_trash?).to eq(true)
      end
    end

    context '2回連続でGameStartを呼ぶと、別々のゲーム番号でそれぞれが開始されること' do
      let!(:first_command_result) do
        command_bus.execute(Commands::GameStart.new)
      end

      it '別々のゲームナンバーのAggregateを構築できること' do
        second_result = subject

        first_aggregate = AggregateTestHelper.load_board_aggregate(first_command_result)
        second_aggregate = AggregateTestHelper.load_board_aggregate(second_result)

        expect(first_aggregate.game_number).not_to eq(second_aggregate.game_number)
      end
    end

    context '5枚だけの山札で復元テスト' do
      let!(:custom_deck_card_strings) do
        GameRule.generate_standard_deck.map(&:to_s).take(GameRule::MAX_HAND_SIZE)
      end

      let!(:command_bus) do
        failure_handler = DummyFailureHandler.new
        CommandBusAssembler.build(
          failure_handler: failure_handler,
          deck_card_strings: custom_deck_card_strings
        )
      end

      it 'イベントをapplyして復元したアグリゲートの手札が元の手札と同じになること' do
        # 最初のゲーム開始
        result = subject
        original_hand_cards = AggregateTestHelper.load_board_aggregate(result).current_hand_cards

        # 新しい空のアグリゲートを作成してイベントをapply
        new_aggregate = Aggregates::BoardAggregate.build_for_new_game
        new_aggregate.apply(result.event)

        # 手札が同じであることを確認
        expect(new_aggregate.current_hand_cards).to eq(original_hand_cards)
      end
    end
  end
end
