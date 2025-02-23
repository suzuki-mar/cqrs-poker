class StartGameUseCase
  def initialize
    @prompt = TTY::Prompt.new
    @pastel = Pastel.new
  end

  def execute
    display_game_start
    handle_game_loop
  end

  private

  def display_game_start
    display_text = <<~TEXT
      #{@pastel.cyan('='*25)}
      #{@pastel.bright_blue('🎮 ポーカーゲーム開始 🎮')}
      #{@pastel.cyan('='*25)}
      [ターン: #{@pastel.green('1')}]
      🃏 初期手札: #{@pastel.red('♥')}5 #{@pastel.black('♠')}A #{@pastel.red('♦')}K #{@pastel.black('♣')}7 #{@pastel.black('♠')}9
      #{@pastel.cyan('-'*25)}
    TEXT

    puts display_text
  end

  def handle_game_loop
    loop do
      selected = @prompt.select('コマンドを選択してください:', [
        { name: '交換する', value: 1 },
        { name: 'ゲーム終了', value: 2 }
      ])

      case selected
      when 1
        handle_card_exchange
      when 2
        handle_game_end
        break
      end
    end
  end

  def handle_card_exchange
    card = @prompt.select('交換するカードを選択してください:', [
      { name: '♥5', value: '♥5' },
      { name: '♠A', value: '♠A' },
      { name: '♦K', value: '♦K' },
      { name: '♣7', value: '♣7' },
      { name: '♠9', value: '♠9' }
    ])
    puts "交換するカード: #{card}"
  end

  def handle_game_end
    puts "#{@pastel.bright_blue('ゲームを終了します')}"
  end
end 