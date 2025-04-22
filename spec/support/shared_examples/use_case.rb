# frozen_string_literal: true

RSpec.shared_examples 'warnログが出力される' do
  it 'warnログが出力されること' do
    subject # コマンド実行
    expect(logger.messages_for_level(:warn).last).to match(/不正な選択肢の選択/)
  end
end
