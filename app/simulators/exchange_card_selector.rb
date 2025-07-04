# typed: true

class ExchangeCardSelector
  def self.execute(player_hand_state, trash_state, strategies = nil)
    new(player_hand_state, trash_state, strategies).execute
  end

  private_class_method :new

  def initialize(player_hand_state, trash_state, strategies = nil)
    @hand_set = player_hand_state.hand_set
    @trash_state = trash_state
    @strategies = strategies || [
      HighCardStrategy.new(hand_set, trash_state),
      FullHouseStrategy.new(hand_set, trash_state),
      FourOfAKindStrategy.new(hand_set, trash_state),
      CompleteHandStrategy.new(hand_set, trash_state)
    ]
  end

  def execute
    # 絶対選択すべき戦略を優先的に探す
    strategies.each do |strategy|
      result = strategy.execute
      return result if result.confidence == EvaluationResult::Confidence::ALREADY_COMPLETE
      return result if result.confidence == EvaluationResult::Confidence::ONE_AWAY_GUARANTEED
    end

    results = strategies.map(&:execute)
    best_result = results.max_by(&:confidence)

    raise ArgumentError, '戦略が設定されていません' unless best_result

    best_result
  end

  private

  attr_reader :hand_set, :trash_state, :strategies
end
