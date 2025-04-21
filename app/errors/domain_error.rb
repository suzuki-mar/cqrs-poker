# frozen_string_literal: true

class DomainError
  attr_reader :message

  def initialize(message)
    @message = message
  end

  def self.game_not_started
    new("ゲームが開始されていません")
  end

  def self.card_not_specified
    new("交換するカードが指定されていません")
  end
end
