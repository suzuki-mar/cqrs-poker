# frozen_string_literal: true

module AssignableIds
  def assign_ids(event_id:, game_number:)
    raise 'event_idは一度しか設定できません' if instance_variable_defined?(:@event_id) && @event_id
    raise 'game_numberは一度しか設定できません' if instance_variable_defined?(:@game_number) && @game_number

    @event_id = event_id
    @game_number = game_number
  end

  def event_id
    @event_id || (raise 'event_idが未設定です')
  end

  def game_number
    @game_number || (raise 'game_numberが未設定です')
  end
end
