module ReadModels
  class PlayerHandState
    def self.load_by_game_number(game_number)
      record = Query::PlayerHandState.find_by(game_number: game_number.value)
      raise "PlayerHandState not found for game_number: \\#{game_number.value}" unless record

      new(record)
    end

    def self.build_from_event(event)
      record = Query::PlayerHandState.new(
        game_number: event.game_number.value,
        hand_set: event.to_event_data[:initial_hand].map(&:to_s),
        current_rank: event.to_event_data[:evaluate],
        current_turn: 1,
        status: 'started',
        last_event_id: event.event_id.value
      )
      new(record)
    end

    private_class_method :new

    def initialize(record)
      @player_hand_state = record
      @game_number = GameNumber.new(record.game_number)
    end

    def start_new_game!(event)
      @player_hand_state = Query::PlayerHandState.find_or_create_by(
        game_number: event.game_number.value
      ) do |record|
        record.status = 'started'
        record.current_rank = event.to_event_data[:evaluate]
        record.current_turn = 1
        record.hand_set = event.to_event_data[:initial_hand].map(&:to_s)
        record.last_event_id = event.event_id.value
      end
    end

    def exchange_card!(event)
      new_hand_set = build_exchanged_hand_set(
        event.to_event_data[:discarded_card],
        event.to_event_data[:new_card]
      )

      # カードが存在しない場合は処理をスキップ
      return if new_hand_set.nil?

      @player_hand_state.hand_set = new_hand_set.cards.map(&:to_s)
      player_hand_state.current_rank = new_hand_set.evaluate
      player_hand_state.current_turn += 1
      player_hand_state.save!
    end

    def current_state_for_display
      {
        status: player_hand_state.status,
        hand: format_hand,
        current_rank: player_hand_state.current_rank,
        rank_name: HandSet.rank_japanese_name(player_hand_state.current_rank),
        turn: player_hand_state.current_turn
      }
    end

    def hand_set
      player_hand_state = self.player_hand_state
      HandSet.build(player_hand_state.hand_set.map { |c| HandSet.build_card(c) })
    end

    def refreshed_hand_set
      # 必ずgame_numberで再取得
      @player_hand_state = Query::PlayerHandState.find_by(game_number: game_number.value)
      hand_set
    end

    def rank_groups
      hand_set.cards
              .group_by(&:number)
              .values
              .select { |group| group.size >= 2 }
    end

    def end_game!(_event)
      player_hand_state.status = 'ended'
      player_hand_state.save!
    end

    delegate :current_turn, :last_event_id, to: :player_hand_state

    attr_reader :game_number

    def self.latest_game_number
      latest_record = Query::PlayerHandState.find_latest_by_event
      raise StandardError, '最新のゲームが見つかりません。' if latest_record.nil?

      GameNumber.new(latest_record.game_number)
    end

    def self.latest_event_id
      latest_record = Query::PlayerHandState.find_latest_by_event
      raise StandardError, '最新のゲームが見つかりません' if latest_record.nil?

      latest_record.last_event_id
    end

    private

    attr_reader :player_hand_state

    def format_hand
      player_hand_state.hand_set.join(' ')
    end

    def build_exchanged_hand_set(discarded_card, new_card)
      hand_set = HandSet.build(player_hand_state.hand_set.map { |c| HandSet.build_card(c) })
      hand_set.rebuild_after_exchange(discarded_card, new_card)
    end
  end
end
