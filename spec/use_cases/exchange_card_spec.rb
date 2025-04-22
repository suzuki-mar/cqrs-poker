# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'カード交換' do
  let(:logger) { TestLogger.new }
  let(:event_publisher) { EventPublisher.new(projection: Projection.new, event_listener: log_event_listener) }
  let(:log_event_listener) { LogEventListener.new(logger) }
  let(:event_bus) { EventBus.new(event_publisher) }
  let(:command_handler) { CommandHandler.new(event_bus) }

  describe 'カード交換時' do
    before do
      GameState.destroy_all
      # ゲームを開始した状態にする
      command_handler.handle(Command.new, CommandContext.build_for_game_start)
      @events = EventStoreHolder.new.load_all_events_in_order
      @board = BoardAggregate.load_from_events(@events)
    end

    context '正常系' do
      let(:command) { Command.new }

      describe '手札のカードを1枚交換できること' do
        let(:read_model) { GameStateReadModel.new }
        let(:discarded_card) { Card.new(GameState.find_current_session.hand_set.first) }
        let(:context) { CommandContext.build_for_exchange(discarded_card) }
        let(:original_hand) { read_model.hand_set }

        it 'イベントが正しく発行されること' do
          published_event = command_handler.handle(Command.new, context)

          expect(published_event).to be_a(CardExchangedEvent)
          expect(published_event.discarded_card.to_s).to eq(discarded_card.to_s)

          stored_event = EventStore.last
          expect(stored_event.event_type).to eq('card_exchanged')
          expect(stored_event.event_data).to include(discarded_card.to_s)
        end

        it '1回だけ手札を交換しても正しく状態が変化すること' do
          command_handler.handle(Command.new, context)

          hand_after = read_model.refreshed_hand_set
          expect(hand_after).not_to include(discarded_card)
          expect(hand_after).not_to eq(original_hand)
        end

        it '2回連続で手札を交換しても正しく状態が変化すること' do
          command_handler.handle(Command.new, context)

          hand_after_first = read_model.refreshed_hand_set
          discarded_card2 = hand_after_first.find_by_number(1)
          context2 = CommandContext.build_for_exchange(discarded_card2)
          command_handler.handle(Command.new, context2)

          hand_after_second = read_model.refreshed_hand_set

          expect(hand_after_second).not_to include(discarded_card2)
          expect(hand_after_second).not_to eq(original_hand)
        end
      end
    end

    xcontext '異常系' do
    end
  end
end
