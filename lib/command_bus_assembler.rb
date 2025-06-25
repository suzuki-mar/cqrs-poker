# frozen_string_literal: true

# CommandBusとその依存関係を組み立てる責務を持つクラス
class CommandBusAssembler
  def self.build(event_publishers: nil, failure_handler: nil, simulator: nil, deck_card_strings: nil)
    new(event_publishers, failure_handler, simulator, deck_card_strings).build
  end

  private_class_method :new

  def initialize(event_publishers, failure_handler, simulator, deck_card_strings)
    @simulator = simulator
    @deck_card_strings = deck_card_strings

    @event_publishers = event_publishers || build_default_publishers
    @failure_handler = failure_handler || @simulator
  end

  # 全ての依存関係が解決されたCommandBusインスタンスを構築して返す
  def build
    event_bus = EventBus.new(event_publishers)
    custom_deck_cards = build_deck_cards
    CommandBus.new(event_bus, failure_handler, custom_deck_cards)
  end

  private

  def build_default_publishers
    projection = EventListener::Projection.new
    # @type var listeners: Array[_EventSubscriber]
    listeners = []
    listeners << simulator if simulator

    event_publisher = EventPublisher.new(
      projection: projection,
      event_listeners: listeners
    )

    [event_publisher]
  end

  def build_deck_cards
    return GameRule.generate_standard_deck unless deck_card_strings

    GameRule.generate_deck_from_strings(deck_card_strings)
  end

  attr_reader :event_publishers, :failure_handler, :simulator, :deck_card_strings
end
