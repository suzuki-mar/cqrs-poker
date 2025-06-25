# frozen_string_literal: true

# テスト用のダミーFailureHandler
# コマンド失敗時の処理を何も行わない
class DummyFailureHandler
  def handle_failure(error); end
end
