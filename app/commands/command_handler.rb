# frozen_string_literal: true

class CommandHandler
  def initialize(event_bus)
    @event_bus = event_bus
    @event_store_holder = EventStoreHolder.new
  end

  def handle(command, context)
    deck = restore_deck

    # TODO: 異常系のテストのときにコメントアウトを解除する
    #    validate_command(command, context)

    event = build_event_by_executing(command, deck, context)

    event_bus.publish(event)
    event
  end

  private

  attr_reader :event_bus, :event_store_holder

  def restore_deck
    deck = Deck.build

    event_store_holder.load_all_events_in_order.each do |event|
      case event
      when GameStartedEvent
        event.initial_hand.cards.each do |card|
          deck.remove_card(card)
        end
      when CardExchangedEvent
        deck.remove_card(event.new_card)
      end
    end

    deck
  end

  def game_started?
    EventStore.exists?(event_type: "game_started")
  end

  def build_event_by_executing(command, deck, context)
    case command
    when GameStartCommand
      initial_hand = command.execute(deck)
      GameStartedEvent.new(initial_hand)
    when ExchangeCardCommand
      discarded_card = context.discarded_card if context.respond_to?(:discarded_card)
      new_card = command.execute(deck)
      CardExchangedEvent.new(discarded_card, new_card)
    else
      raise InvalidCommand, "不明なコマンドです: #{command.class.name}"
    end
  end

  # TODO 後で実装をする
  def validate_command(command, context)
    # case command
    # when ExchangeCardCommand
    #   return DomainError.game_not_started unless game_started?
    #   return DomainError.card_not_specified unless context.discarded_card
    # end

    # nil
  end
end
