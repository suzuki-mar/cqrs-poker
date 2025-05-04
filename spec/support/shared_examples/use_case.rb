# frozen_string_literal: true

RSpec.shared_examples 'warnログが出力される' do
  it 'warnログが出力されること' do
    subject # コマンド実行
    expect(logger.messages_for_level(:warn).last).to match(/不正な選択肢の選択/)
  end
end

RSpec.shared_examples 'version conflict event' do
  it 'ユースケース経由でバージョン競合が発生した場合、VersionConflictが返ること' do
    # 1回目のゲーム開始（正常）
    result1 = command_bus.execute(Command.new, context)
    expect(result1).to be_a(SuccessEvents::GameStarted)

    # 2回目のゲーム開始（バージョン競合を発生させる）
    result2 = command_bus.execute(Command.new, context)
    expect(result2).to be_a(CommandErrors::VersionConflict)
  end
end
