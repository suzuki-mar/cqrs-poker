module ReadModels
  class ProjectionVersions
    class VersionInfo
      attr_reader :projection_name, :last_event_id

      def initialize(projection_name, last_event_id)
        @projection_name = projection_name
        @last_event_id = last_event_id
      end
    end

    def self.load
      version_infos = Query::ProjectionVersion.for_game(nil).map do |pv|
        VersionInfo.new(pv.projection_name, EventId.new(pv.event_id))
      end
      new(version_infos)
    end

    def initialize(version_infos)
      @version_infos = version_infos
    end

    def fetch_all_versions
      @version_infos
    end

    def self.update_all_versions(event)
      versions = Query::ProjectionVersion.for_game(event.game_number.value).index_by(&:projection_name)
      Query::ProjectionVersion.projection_names.each_key do |name|
        pv = versions[name] || Query::ProjectionVersion.new(projection_name: name, game_number: event.game_number.value)
        pv.event_id = event.event_id.value
        pv.game_number = event.game_number.value
        pv.save!
      end
    end
  end
end
