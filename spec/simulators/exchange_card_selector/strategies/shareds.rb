# typed: false

# 戦略適用の共通パターン
shared_examples '指定されたカードを交換すること' do |expected_exchange_cards, expected_confidence|
  it do
    expect(subject.exchange_cards.map(&:number).sort).to eq(expected_exchange_cards.sort)
    expect(subject.confidence).to eq(expected_confidence)
  end
end

# 戦略不適用の共通パターン
shared_examples '戦略不適用を返すこと' do
  it do
    expect(subject.exchange_cards).to be_empty
    expect(subject.confidence).to eq(ExchangeCardSelector::EvaluationResult::Confidence::DO_NOT_EXCHANGE)
  end
end

# 完成役の共通パターン
shared_examples '完成役として交換しないこと' do
  it do
    expect(subject.exchange_cards).to be_empty
    expect(subject.confidence).to eq(ExchangeCardSelector::EvaluationResult::Confidence::ALREADY_COMPLETE)
  end
end
