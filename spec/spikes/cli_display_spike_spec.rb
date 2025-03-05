require 'rails_helper'
require 'tty-prompt'
require 'pastel'
require 'stringio'

RSpec.describe 'CLIの表示のスパイクテスト' do
  let(:prompt) { TTY::Prompt.new }
  let(:pastel) { Pastel.new }
  let(:output) { StringIO.new }

  around do |example|
    original_stdout = $stdout
    $stdout = output
    example.run
    $stdout = original_stdout
  end

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

    expect(output.string).to include('ポーカーゲーム開始')

    # テスト用に入力をシミュレートする
    allow(prompt).to receive(:select).and_return(1)

    selected = prompt.select('コマンドを選択してください:', [
      { name: '交換する', value: 1 },
      { name: 'ゲーム終了', value: 2 }
    ])

    expect(selected).to eq(1)

    # 交換するカードの選択もシミュレート
    allow(prompt).to receive(:select).and_return('♠A')

    card = prompt.select('交換するカードを選択してください:', [
      { name: '♥5', value: '♥5' },
      { name: '♠A', value: '♠A' },
      { name: '♦K', value: '♦K' },
      { name: '♣7', value: '♣7' },
      { name: '♠9', value: '♠9' }
    ])

    expect(card).to eq('♠A')
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

    expect(output.string).to include('交換:')
  end
end
