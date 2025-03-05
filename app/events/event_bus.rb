# typed: true

require "singleton"
require "active_support/notifications"

class EventBus
  include Singleton

  def initialize
    @action_completed_listener = nil
  end

  # アクションが完了したときにイベントを発行する
  def notify_when_action_completed(action)
    ActiveSupport::Notifications.instrument("action_completed", action: action)
    @action_completed_listener.call(action) if @action_completed_listener
    Rails.logger.info "Action completed: #{action}"
  end

  # アクション完了のリスナーを登録する
  def register_action_completed_listener(listener)
    if @action_completed_listener.nil?
      @action_completed_listener = listener
      @subscription = ActiveSupport::Notifications.subscribe("action_completed") do |_name, _start, _finish, _id, payload|
        listener.call(payload[:action])
      end
      Rails.logger.debug "Listener registered: #{@subscription}"
    else
      Rails.logger.debug "Listener registration skipped: already registered"
    end
  end

  private
  attr_reader :action_completed_listener
end
