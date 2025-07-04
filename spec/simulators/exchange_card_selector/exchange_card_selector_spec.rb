# typed: false

require 'rails_helper'

RSpec.describe ExchangeCardSelector do
  subject { described_class.execute(query_service.player_hand_state, query_service.trash_state) }

  let(:query_service) { QueryService.new(game_number) }
  let!(:command_bus) do
    failure_handler = DummyFailureHandler.new
    CommandBusAssembler.build(
      failure_handler: failure_handler
    )
  end
  let!(:game_number) do
    command_bus.execute(Commands::GameStart.new)
    QueryService.latest_game_number
  end

  context '基本的な動作確認' do
    it '戦略から結果を取得できること' do
      result = subject
      expect(result).to be_a(ExchangeCardSelector::EvaluationResult)
      expect(result.confidence).to be_a(Integer)
      expect(result.exchange_cards).to be_a(Array)
    end

    it '結果が適切に返されること' do
      result = subject
      expect(result).to be_a(ExchangeCardSelector::EvaluationResult)
      expect(result.confidence).to be >= 0
      expect(result.exchange_cards).to be_a(Array)
    end
  end

  context '戦略が空の場合' do
    it 'ArgumentErrorが発生すること' do
      expect do
        described_class.execute(query_service.player_hand_state, query_service.trash_state, [])
      end.to raise_error(ArgumentError, '戦略が設定されていません')
    end
  end
end
