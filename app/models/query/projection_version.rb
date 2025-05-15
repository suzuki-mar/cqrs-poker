module Query
  class ProjectionVersion < ApplicationRecord
    include DefineGameNumberColumn
    enum :projection_name, { player_hand_state: 'player_hand_state', trash: 'trash' }

    validates :event_id, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
    validates :projection_name, presence: true, inclusion: { in: projection_names.keys }

    def self.find_or_build_all_by_game_number(game_number)
      versions = where(game_number: game_number.value).index_by(&:projection_name)
      projection_names.each_key.map do |name|
        versions[name] || new(projection_name: name, game_number: game_number.value)
      end
    end

    def self.projection_name_and_event_id_pairs(game_number)
      where(game_number: game_number.value).map do |pv|
        [pv.projection_name, EventId.new(pv.event_id)]
      end
    end
  end
end
