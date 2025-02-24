require 'rails_helper'

RSpec.describe GameState, type: :model do
  shared_examples '手札のバリデーション' do |hand_number|
    it { should validate_presence_of(:"hand_#{hand_number}") }
  end

  describe 'バリデーション' do
    describe '手札' do
      describe 'hand_1' do
        include_examples '手札のバリデーション', 1

        describe 'フォーマット' do
          subject { build(:game_state, hand_1: card_value) }

          context '正常なフォーマット' do
            context 'スートがあっている場合' do
              let!(:suit) { '♠' }
                
              context '数字が仕様をみたしている場合' do
                context '2-10の場合' do
                  %w[2 3 4 5 6 7 8 9 10].each do |number|
                    let(:card_value) { "#{suit}#{number}" }
                    it { should be_valid }
                  end
                end

                context '数字がA,J,Q,Kの場合' do
                  %w[A J Q K].each do |face|
                    let(:card_value) { "#{suit}#{face}" }
                    it { should be_valid }
                  end
                end
              end

              context '数字が仕様をみたしていない場合' do
                context '1は不正な値' do
                  let(:card_value) { "#{suit}1" }
                  it { should be_invalid }
                end

                context '11は不正な値' do
                  let(:card_value) { "#{suit}11" }
                  it { should be_invalid }
                end

                context '指定したアルファベットではない場合' do
                  let(:card_value) { "#{suit}x" }
                  it { should be_invalid }
                end
              end
            end

            context 'スートが間違っている場合' do
              context 'トランプのスート以外の文字の場合' do
                let(:card_value) { '@A' }  # 明らかに不正なスート
                it { should be_invalid }
              end
              
            end
          end # 正常なフォーマット
        end # フォーマット
      end

      # describe 'hand_2' do
      #   include_examples '手札のバリデーション', 2
      # end

      # describe 'hand_3' do
      #   include_examples '手札のバリデーション', 3
      # end

      # describe 'hand_4' do
      #   include_examples '手札のバリデーション', 4
      # end

      # describe 'hand_5' do
      #   include_examples '手札のバリデーション', 5
      # end
    end

    describe 'current_rank' do
      it { should validate_presence_of(:current_rank) }
      it { should validate_inclusion_of(:current_rank).in_array(GameState::VALID_RANKS) }

      describe '不正な値' do
        subject { build(:game_state, current_rank: invalid_value) }

        context '存在しない役の場合' do
          let(:invalid_value) { 'INVALID_HAND' }
          it { should be_invalid }
        end
      end
    end

    describe 'current_turn' do
      it { should validate_presence_of(:current_turn) }
      it { should validate_numericality_of(:current_turn)
             .only_integer
             .is_greater_than_or_equal_to(1)
             .is_less_than_or_equal_to(100) }

      describe '不正な値' do
        subject { build(:game_state, current_turn: invalid_value) }

        context '0以下の値の場合' do
          let(:invalid_value) { 0 }
          it { should be_invalid }
        end

        context '小数の場合' do
          let(:invalid_value) { 1.5 }
          it { should be_invalid }
        end

        context '上限値を超える場合' do
          let(:invalid_value) { 1000 }
          it { should be_invalid }
        end
      end
    end
  end
end 