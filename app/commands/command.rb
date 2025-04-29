# このCommandクラスは、CQRS+ESのデモ・学習用途のために「コマンド＝意図」を1クラスで集約しています。
# 実運用ではコマンドごとにクラスを分けることが多いですが、
# 本プロジェクトでは「コマンドの種類ごとにメソッドを分ける」ことで、
# ・全体像の俯瞰性
# ・デモやCLI操作のシンプルさ
# ・学習時の見通しの良さ
# を重視しています。

# frozen_string_literal: true

class Command
  def execute_for_game_start(board)
    board.draw_initial_hand
  end

  def execute_for_exchange_card(board)
    board.draw
  end

  def execute_for_end_game(board)
    # ゲーム終了時には何もしない
  end
end
