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

    def self.update_all_versions(event_id)
      versions = Query::ProjectionVersion.for_game(nil).index_by(&:projection_name)
      Query::ProjectionVersion.projection_names.each_key do |name|
        pv = versions[name] || Query::ProjectionVersion.new(projection_name: name)
        pv.event_id = event_id.value
        pv.save!
      end
    end
  end
end
