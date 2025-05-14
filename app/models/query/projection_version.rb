module Query
  class ProjectionVersion < ApplicationRecord
    enum :projection_name, { player_hand_state: 'player_hand_state', trash: 'trash' }

    validates :event_id, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
    validates :projection_name, presence: true, inclusion: { in: projection_names.keys }

    def self.for_game(_game_id)
      all
    end
  end
end
