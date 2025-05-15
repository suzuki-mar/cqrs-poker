module ReadModels
  class ProjectionVersions
    class VersionInfo
      attr_reader :projection_name, :last_event_id

      def initialize(projection_name, last_event_id)
        @projection_name = projection_name
        @last_event_id = last_event_id
      end
    end

    def self.load(game_number)
      version_infos = Query::ProjectionVersion.projection_name_and_event_id_pairs(game_number).map do |name, event_id|
        VersionInfo.new(name, event_id)
      end
      new(version_infos)
    end

    def initialize(version_infos)
      @version_infos = version_infos
    end

    private_class_method :new

    def fetch_all_versions
      @version_infos
    end

    def self.update_all_versions(event)
      Query::ProjectionVersion.find_or_build_all_by_game_number(event.game_number).each do |pv|
        pv.event_id = event.event_id.value
        pv.save!
      end
    end
  end
end
