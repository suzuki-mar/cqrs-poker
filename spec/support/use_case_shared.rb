# frozen_string_literal: true

RSpec.shared_examples 'version history update examples' do
  context 'バージョン履歴が揃っている場合（use_case_shared）' do
    before do
      command_bus.execute(GameStartCommand.new)
    end

    it 'バージョン履歴をアップデートをしていること' do
      start_event = Aggregates::Store.new.latest_event

      subject

      main_event = Aggregates::Store.new.latest_event

      expect(start_event.event_id).to be < main_event.event_id

      version_info = ReadModels::ProjectionVersions.load(main_event.game_number)
      version_ids = version_info.fetch_all_versions.map(&:last_event_id)
      expect(version_ids).to all(eq(main_event.event_id))
    end
  end

  context 'バージョン履歴が揃っていない場合' do
    before do
      command_bus.execute(GameStartCommand.new)
    end

    it 'バージョン履歴をアップデートをしていること' do
      start_event_id = Aggregates::Store.new.latest_event.event_id

      versions = Query::ProjectionVersion.projection_names.keys
      Query::ProjectionVersion.find_or_create_by!(projection_name: versions[0]).update!(event_id: start_event_id.value)

      subject
      main_event = Aggregates::Store.new.latest_event

      version_info = ReadModels::ProjectionVersions.load(main_event.game_number)
      version_ids = version_info.fetch_all_versions.map(&:last_event_id)
      expect(version_ids).to all(eq(main_event.event_id))
    end
  end
end
