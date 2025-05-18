require 'securerandom'

class GameNumber
  include Comparable

  attr_reader :value

  def initialize(value)
    @value = value.to_i
  end

  def self.build
    min = 10_000
    max = 99_999
    loop do
      candidate = SecureRandom.random_number(max - min + 1) + min
      return new(candidate) unless Event.exists?(game_number: candidate)
    end
  end

  def <=>(other)
    return nil unless other.is_a?(GameNumber)

    value <=> other.value
  end

  def ==(other)
    other.is_a?(GameNumber) && value == other.value
  end

  delegate :to_s, to: :value
end
