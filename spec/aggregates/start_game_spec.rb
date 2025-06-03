require 'rails_helper'

RSpec.describe 'ゲーム開始コマンド後のAggregateの詳細状態' do
  let(:command_bus) do
    logger = TestLogger.new
    UseCaseHelper.build_command_bus(logger)
  end

  let(:aggregate_store) { Aggregates::Store.new }

  subject { command_bus.execute(Commands::GameStart.new) }

  describe '正常系' do
    context '初回のゲーム開始でAggregateが存在する状態になること' do
      it 'Aggregateの状態が正しいこと' do
        result = subject
        game_number = result.event.game_number
        board_aggregate = aggregate_store.load_board_aggregate_for_current_state(game_number)

        aggregate_failures do
          expect(board_aggregate.exists_game?).to be true
          expect(board_aggregate.game_in_progress?).to be true
          expect(board_aggregate.game_ended?).to be false
        end
      end

      it 'AggregateのTrashは作成されているが空のままであること' do
        result = subject
        game_number = result.event.game_number
        board_aggregate = aggregate_store.load_board_aggregate_for_current_state(game_number)
        expect(board_aggregate.trash.cards).to be_empty
      end
    end

    context '2回連続でGameStartを呼ぶと、別々のゲーム番号でそれぞれが開始されること' do

      let!(:first_game_number) do
        result = command_bus.execute(Commands::GameStart.new)
        result.event.game_number
      end

      it 'それぞれのアグリゲートを構築できること' do
        second_result = subject
        second_game_number = second_result.event.game_number

        # 2つの異なるゲーム番号が生成されることを確認
        expect(first_game_number).not_to eq(second_game_number)

        # それぞれのアグリゲートを再構築してgame_in_progress: true であること
        [first_game_number, second_game_number].each do |game_number|
          board_aggregate = aggregate_store.load_board_aggregate_for_current_state(game_number)
          expect(board_aggregate.game_in_progress?).to be true
        end
      end
    end
  end
end
