# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ゲーム終了ユースケース' do
  let(:logger) { TestLogger.new }
  let!(:command_bus) { UseCaseHelper.build_command_bus(logger) }
  let(:read_model) { ReadModels::PlayerHandState.new }
  let(:context) { CommandContext.build_for_end_game }

  context '正常系' do
    before do
      # まずゲームを開始しておく
      command_bus.execute(Command.new, CommandContext.build_for_game_start)
    end

    subject { command_bus.execute(Command.new, context) }

    it 'GameEndedEventがEventStoreに記録されること' do
      subject
      event = Event.last
      expect(event.event_type).to eq(GameEndedEvent.event_type)
    end

    it 'ログにゲーム終了が記録されること' do
      subject
      expect(logger.messages_for_level(:info)).to include(/イベント受信: ゲーム終了/)
    end

    it 'PlayerHandStateの状態が終了済みになること' do
      subject
      player_game_state = Query::PlayerHandState.find_current_session
      expect(player_game_state.status).to eq('ended')
    end

    it 'Historyクラスが生成され、最終手札とcurrentRankを保持していること' do
      subject
      histories = ReadModels::Histories.load(limit: 1)
      history = histories.first
      read_model = ReadModels::PlayerHandState.new

      expect(history).not_to be_nil
      expect(history.hand_set).to eq(read_model.hand_set.cards.map(&:to_s))
      expect(history.rank).to eq(HandSet::Rank::ALL.index(read_model.hand_set.evaluate))
    end
  end

  context '異常系' do
    it 'ゲームが開始されていない状態で終了しようとするとInvalidCommandEventが発行されること' do
      result = command_bus.execute(Command.new, context)
      expect(result.error).to be_a(CommandErrors::InvalidCommand)
      expect(result.error.reason).to eq('ゲームが進行中ではありません')
    end
  end
end
