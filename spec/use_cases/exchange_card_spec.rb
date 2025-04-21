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
      command_handler.handle(GameStartCommand.execute(Deck.build))
    end

    context '正常系' do
      describe '手札のカードを1枚交換できること' do
        it 'イベントが正しく発行されること' do
          discarded_card = Faker.valid_card
          command = ExchangeCardCommand.new
          payload = { discarded_card: discarded_card }

          expect {
            published_event = command_handler.handle(command, payload)
            expect(published_event).to be_a(CardExchangedEvent)
            expect(published_event.discarded_card.to_s).to eq(discarded_card)
          }.to change(EventStore, :count).by(1)

          # イベントストアに正しく記録されていることを検証
          stored_event = EventStore.last
          expect(stored_event.event_type).to eq('card_exchanged')
          expect(stored_event.event_data).to include_json(discarded_card: discarded_card)
        end



        xit '新しいカードが手札に加わること' do
          game_state = GameState.last
          original_hand = game_state.current_hand_set.dup
          discarded_card = game_state.hand_1
          payload = { discarded_card: discarded_card }

          command_handler.handle(ExchangeCardCommand.new, payload)

          game_state.reload
          new_hand = game_state.current_hand_set
          expect(new_hand).not_to include(discarded_card)
          expect(new_hand.size).to eq(original_hand.size)
          expect(new_hand).not_to eq(original_hand)
        end
      end
    end

    xcontext '異常系' do
    end
  end
end
