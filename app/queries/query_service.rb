class QueryService
  def initialize(game_number)
    @game_number = game_number
    @projection_versions = nil
  end

  def player_hand_set
    phs = ReadModels::PlayerHandState.load_by_game_number(game_number)
    phs.hand_set
  end

  def all_projection_versions
    projection_versions.fetch_all_versions
  end

  def player_hand_summary
    phs = ReadModels::PlayerHandState.load_by_game_number(game_number)
    {
      hand_set: phs.hand_set.cards.map(&:to_s),
      rank: HandSet::Rank::ALL.index(phs.hand_set.evaluate),
      status: phs.current_state_for_display[:status]
    }
  end

  def ended_game_recorded?
    ReadModels::Histories.load(game_number).any?
  end

  def self.latest_game_number
    ReadModels::PlayerHandState.latest_game_number
  end

  def self.latest_event_id
    ReadModels::PlayerHandState.latest_event_id
  end

  def self.build_last_game_query_service
    game_number = latest_game_number
    new(game_number)
  end

  def self.last_game_player_hand_summary
    build_last_game_query_service.player_hand_summary
  end

  def trash_state
    ReadModels::TrashState.load(game_number)
  end

  def self.number_of_games
    ReadModels::ProjectionVersions.count_group_game_number
  end

  private

  def projection_versions
    @projection_versions ||= ReadModels::ProjectionVersions.load(game_number)
  end

  attr_reader :game_number
end
