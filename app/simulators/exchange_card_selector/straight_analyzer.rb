# typed: true

class ExchangeCardSelector
  class StraightAnalyzer
    def initialize(hand_set)
      @hand_set = hand_set
    end

    def matching_card_count
      values = sorted_card_values
      calculate_max_consecutive(values)
    end

    def exchange_cards_for_count(count)
      cards = sorted_cards
      values = sorted_card_values
      consecutive_range = find_longest_consecutive_range(values)

      non_consecutive_cards = find_non_consecutive_cards(cards, consecutive_range)
      select_lowest_value_cards(non_consecutive_cards, count)
    end

    private

    attr_reader :hand_set

    def sorted_card_values
      hand_set.cards.map { |card| card_value(card) }.uniq.sort
    end

    def sorted_cards
      hand_set.cards.sort_by { |card| card_value(card) }
    end

    def calculate_max_consecutive(values)
      consecutive_sequences = find_consecutive_sequences(values)
      consecutive_sequences.map { |_, length| length }.max
    end

    def consecutive_numbers?(current, previous)
      current == previous + 1
    end

    def find_non_consecutive_cards(cards, consecutive_range)
      cards.reject { |card| consecutive_range.include?(card_value(card)) }
    end

    def select_lowest_value_cards(cards, count)
      cards.sort_by { |card| card_value(card) }.take(count)
    end

    def find_longest_consecutive_range(values)
      consecutive_sequences = find_consecutive_sequences(values)
      start_value, length = consecutive_sequences.max_by { |_, length| length } || [0, 0]
      (start_value...(start_value + length))
    end

    def find_consecutive_sequences(values)
      return handle_single_value_case(values) if values.size == 1

      process_consecutive_calculation(values)
    end

    def handle_single_value_case(values)
      [[values[0], 1]]
    end

    def process_consecutive_calculation(values)
      sequences = [] # : Array[[Integer, Integer]]

      scan_consecutive_values(values, sequences)
    end

    def scan_consecutive_values(values, sequences)
      current_start = values[0]
      current_length = 1

      (1...values.size).each do |i|
        current_start, current_length = update_sequence_state(
          values[i], values[i - 1], sequences, current_start, current_length
        )
      end

      finalize_sequences(sequences, current_start, current_length)
    end

    def update_sequence_state(current_value, previous_value, sequences, current_start, current_length)
      if consecutive_numbers?(current_value, previous_value)
        [current_start, current_length + 1]
      else
        sequences << [current_start, current_length]
        [current_value, 1]
      end
    end

    def finalize_sequences(sequences, current_start, current_length)
      sequences << [current_start, current_length]
      sequences
    end

    def card_value(card)
      HandSet::Evaluator::NUMBER_TO_VALUE[card.number]
    end
  end
end
