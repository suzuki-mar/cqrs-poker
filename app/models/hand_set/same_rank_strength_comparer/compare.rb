# frozen_string_literal: true

class HandSet::SameRankStrengthComparer
  class Compare
    def initialize(values1, values2)
      @values1 = Array(values1).freeze
      @values2 = Array(values2).freeze
    end

    def compare
      values1.zip(values2).each do |v1, v2|
        nil_compare(v1, v2) if v1.nil? || v2.nil?

        comparison = v1 <=> v2
        return comparison unless comparison.zero?
      end

      0
    end

    private

    def nil_compare(value1, value2)
      return 1 if value2.nil? && !value1.nil?
      return -1 if value1.nil? && !value2.nil?
      return 0 if value1.nil? && value2.nil?

      nil
    end

    attr_reader :values1, :values2
  end
end
