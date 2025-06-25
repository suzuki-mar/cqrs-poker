require 'rails_helper'

RSpec.describe 'シミュレーターの基本動作' do
  let!(:logger) { TestLogger.new }
  let!(:simulator) { Simulator.new(logger) }

  subject { simulator.run(command_bus) }

  describe 'シミュレーターの連続実行' do
    let!(:command_bus) do
      CommandBusAssembler.build(
        failure_handler: simulator,
        simulator: simulator
      )
    end

    it 'ログが順番通りに書き込まれていること' do
      expected_messages = [
        'Simulator: イベント[GameStartedEvent]を処理しました。',
        '初期手札:',
        'を最初に引きました',
        'Simulator: イベント[CardExchangedEvent]を処理しました。',
        'Simulator: イベント[GameEndedEvent]を処理しました。'
      ]

      subject

      log_output = logger.full_log

      # 各メッセージの出現位置を取得
      positions = expected_messages.map { |message| log_output.index(message) }

      # 順番が正しいか確認（後のメッセージほど大きなインデックス）
      expect(positions).to eq(positions.sort)
      # 全てのメッセージが見つかることも確認
      expect(positions).to all(be_present)
    end

    describe '指定したカードの山札になっていること' do
      let!(:command_bus) do
        CommandBusAssembler.build(
          failure_handler: simulator,
          simulator: simulator,
          deck_card_strings: custom_deck_card_strings
        )
      end

      let!(:custom_deck_card_strings) do
        Array.new(GameRule::MAX_HAND_SIZE * 2) { CustomFaker.valid_card.to_s }
      end

      it '指定された山札から引いたカードが配られていること' do
        extract_dealt_cards = lambda do |log|
          hand_match = log.match(/初期手札: (.+) を最初に引きました/)
          hand_match[1].split
        end

        subject

        log_output = logger.full_log
        actual_hand_cards = extract_dealt_cards.call(log_output)
        expected_hand_cards = custom_deck_card_strings[0, GameRule::MAX_HAND_SIZE]

        expect(actual_hand_cards).to eq(expected_hand_cards)
      end
    end
  end
end
