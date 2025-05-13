class EventId
  include Comparable

  attr_reader :value

  def initialize(value)
    @value = value.to_i
  end

  def <=>(other)
    value <=> other.value
  end

  def ==(other)
    other.is_a?(EventId) && value == other.value
  end

  delegate :to_s, to: :value
end
