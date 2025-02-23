class StartGameUseCase
  def initialize
    @prompt = TTY::Prompt.new
    @pastel = Pastel.new
  end

  def execute
    # 今は空のメソッド
    # 将来的にはRakeタスクに表示情報を返す
  end

  
end 