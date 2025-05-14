# frozen_string_literal: true

RSpec.shared_examples 'game_id column examples' do
  it 'game_idを設定・取得できること' do
    model = described_class.new(game_id: 123)
    expect(model.game_id).to eq 123
  end

  it 'to_game_idでGameId値オブジェクトを取得できること' do
    model = described_class.new(game_id: 456)
    expect(model.to_game_id).to eq GameId.new(456)
    expect(model.to_game_id).to be_a(GameId)
  end
end

RSpec.shared_examples 'last_event_id column examples' do
  it 'last_event_idを設定・取得できること' do
    model = described_class.new(last_event_id: 42)
    expect(model.last_event_id).to eq 42
  end

  it 'to_event_idでEventId値オブジェクトを取得できること' do
    model = described_class.new(last_event_id: 99)
    expect(model.to_event_id).to eq EventId.new(99)
    expect(model.to_event_id).to be_a(EventId)
  end
end

RSpec.shared_examples 'game_number column examples' do
  it 'game_numberを設定・取得できること' do
    model = described_class.new(game_number: 123)
    expect(model.game_number).to eq 123
  end

  it 'to_game_numberでGameNumber値オブジェクトを取得できること' do
    model = described_class.new(game_number: 456)
    expect(model.to_game_number).to eq GameNumber.new(456)
    expect(model.to_game_number).to be_a(GameNumber)
  end
end
