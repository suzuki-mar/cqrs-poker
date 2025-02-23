require 'rails_helper'
require 'tty-prompt'
require 'pastel'

RSpec.describe 'CLIの表示のスパイクテスト' do
  let(:prompt) { TTY::Prompt.new }
  let(:pastel) { Pastel.new }

  it 'ゲーム開始時の表示と入力を確認する' do
    display_text = <<~TEXT
      #{pastel.cyan('='*25)}
      #{pastel.bright_blue('🎮 ポーカーゲーム開始 🎮')}
      #{pastel.cyan('='*25)}
      [ターン: #{pastel.green('1')}]
      🃏 初期手札: #{pastel.red('♥')}5 #{pastel.black('♠')}A #{pastel.red('♦')}K #{pastel.black('♣')}7 #{pastel.black('♠')}9
      #{pastel.cyan('-'*25)}
    TEXT

    puts display_text

    # 実際に選択できるようにコメントアウトを外す
    selected = prompt.select('コマンドを選択してください:', [
      { name: '交換する', value: 1 },
      { name: 'ゲーム終了', value: 2 }
    ])

    puts "選択されたコマンド: #{selected}"

    # 交換する場合は、どのカードを交換するか選択
    if selected == 1
      card = prompt.select('交換するカードを選択してください:', [
        { name: '♥5', value: '♥5' },
        { name: '♠A', value: '♠A' },
        { name: '♦K', value: '♦K' },
        { name: '♣7', value: '♣7' },
        { name: '♠9', value: '♠9' }
      ])
      
      puts "交換するカード: #{card}"
    end

    expect(true).to be true
  end

  it 'カード交換時の表示を確認する' do
    display_text = <<~TEXT
      #{pastel.cyan('='*25)}
      [ターン: #{pastel.green('1')}]
      🃏 交換: #{pastel.red('♥')}5 → #{pastel.black('♠')}J
      🃏 新しい手札: #{pastel.black('♠')}A #{pastel.red('♦')}K #{pastel.black('♠')}J #{pastel.black('♣')}7 #{pastel.black('♠')}9
      #{pastel.cyan('-'*25)}
    TEXT

    puts display_text

    expect(true).to be true
  end
end 