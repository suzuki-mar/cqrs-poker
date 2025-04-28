# frozen_string_literal: true

RSpec.shared_examples 'warnログが出力される' do
  it 'warnログが出力されること' do
    subject # コマンド実行
    expect(logger.messages_for_level(:warn).last).to match(/不正な選択肢の選択/)
  end
end

RSpec.shared_examples 'version conflict event' do
  it 'バージョン競合エラー（version_conflict）が返ること' do
    raise 'eventがletで定義されていません' if event.nil?
    raise 'error_versionがletで定義されていません' if error_version.nil?

    aggregate_store = AggregateStore.new
    aggregate_store.append(event, error_version) # 1回目（正常）
    result = aggregate_store.append(event, error_version) # 2回目（競合）
    raise 'shared_examplesの使い方エラー: 1回目のappend（正常登録）が実行されていません' if result.success?

    expect(result.failure[0]).to eq(VersionConflictEvent.event_type)
    expect(result.failure[1]).to be_a(VersionConflictEvent)
  end
end
