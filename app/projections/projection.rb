# イベントを受け取り、GameStateの状態を更新するProjectionクラス。
#
# 本プロジェクトでは、イベントの種類が少なく（GameStarted, CardExchanged, GameEnded）、
# 状態の更新も単純なため、単一のProjectionクラスで全てのイベントを処理します。
class Projection
  def initialize
    @read_model = GameStateReadModel.new
  end

  def receive(event)
    case event.event_type
    when EventType::GAME_STARTED
      @read_model.update_for_game_started(event)
      Rails.logger.info "ゲーム開始イベントを処理しました: #{event.to_event_data}"
    else
      Rails.logger.warn "未対応のイベントタイプです: #{event.event_type}"
    end
  end
end
