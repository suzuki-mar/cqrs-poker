require 'rails_helper'
require 'support/custom_faker'

RSpec.describe HandSet::SameRankStrengthComparer do
  describe '.call' do
    context 'ハイカード同士の比較' do
      it 'より高いカードを持つ手札が勝つ' do
        hand1 = HandSet.build([
                                HandSet.build_card('♠A'),
                                HandSet.build_card('♥K'),
                                HandSet.build_card('♦Q'),
                                HandSet.build_card('♣J'),
                                HandSet.build_card('♠9')
                              ])

        hand2 = HandSet.build([
                                HandSet.build_card('♠A'),
                                HandSet.build_card('♥K'),
                                HandSet.build_card('♦Q'),
                                HandSet.build_card('♣J'),
                                HandSet.build_card('♠8')
                              ])

        result = described_class.call(hand1, hand2)
        expect(result).to eq(1)
      end
    end

    context 'ワンペア同士の比較' do
      it 'より高いペアが勝つ' do
        ace_pair = HandSet.build([
                                   HandSet.build_card('♠A'),
                                   HandSet.build_card('♥A'),
                                   HandSet.build_card('♦3'),
                                   HandSet.build_card('♣5'),
                                   HandSet.build_card('♠7')
                                 ])

        king_pair = HandSet.build([
                                    HandSet.build_card('♠K'),
                                    HandSet.build_card('♥K'),
                                    HandSet.build_card('♦3'),
                                    HandSet.build_card('♣5'),
                                    HandSet.build_card('♠7')
                                  ])

        result = described_class.call(ace_pair, king_pair)
        expect(result).to eq(1)
      end

      it '同じペアなら残りのカードが強いほうがが勝つ' do
        ace_pair_king_kicker = HandSet.build([
                                               HandSet.build_card('♠A'),
                                               HandSet.build_card('♥A'),
                                               HandSet.build_card('♦K'),
                                               HandSet.build_card('♣5'),
                                               HandSet.build_card('♠7')
                                             ])

        ace_pair_queen_kicker = HandSet.build([
                                                HandSet.build_card('♠A'),
                                                HandSet.build_card('♥A'),
                                                HandSet.build_card('♦Q'),
                                                HandSet.build_card('♣5'),
                                                HandSet.build_card('♠7')
                                              ])

        result = described_class.call(ace_pair_king_kicker, ace_pair_queen_kicker)
        expect(result).to eq(1)
      end
    end

    context 'ツーペア同士の比較' do
      it 'より高いペアを持つ手札が勝つ' do
        aces_and_kings = HandSet.build([
                                         HandSet.build_card('♠A'),
                                         HandSet.build_card('♥A'),
                                         HandSet.build_card('♦K'),
                                         HandSet.build_card('♣K'),
                                         HandSet.build_card('♠Q')
                                       ])

        aces_and_queens = HandSet.build([
                                          HandSet.build_card('♠A'),
                                          HandSet.build_card('♥A'),
                                          HandSet.build_card('♦Q'),
                                          HandSet.build_card('♣Q'),
                                          HandSet.build_card('♠K')
                                        ])

        result = described_class.call(aces_and_kings, aces_and_queens)
        expect(result).to eq(1)
      end
    end

    context 'スリーカード同士の比較' do
      it 'より高いスリーカードが勝つ' do
        three_aces = HandSet.build([
                                     HandSet.build_card('♠A'),
                                     HandSet.build_card('♥A'),
                                     HandSet.build_card('♦A'),
                                     HandSet.build_card('♣5'),
                                     HandSet.build_card('♠7')
                                   ])

        three_kings = HandSet.build([
                                      HandSet.build_card('♠K'),
                                      HandSet.build_card('♥K'),
                                      HandSet.build_card('♦K'),
                                      HandSet.build_card('♣5'),
                                      HandSet.build_card('♠7')
                                    ])

        result = described_class.call(three_aces, three_kings)
        expect(result).to eq(1)
      end
    end

    context 'ストレート同士の比較' do
      it 'より高いストレートが勝つ' do
        high_straight = HandSet.build([
                                        HandSet.build_card('♠10'),
                                        HandSet.build_card('♥J'),
                                        HandSet.build_card('♦Q'),
                                        HandSet.build_card('♣K'),
                                        HandSet.build_card('♠A')
                                      ])

        low_straight = HandSet.build([
                                       HandSet.build_card('♠2'),
                                       HandSet.build_card('♥3'),
                                       HandSet.build_card('♦4'),
                                       HandSet.build_card('♣5'),
                                       HandSet.build_card('♠6')
                                     ])

        result = described_class.call(high_straight, low_straight)
        expect(result).to eq(1)
      end

      it 'A-2-3-4-5のホイールは5ハイとして扱われる' do
        wheel = HandSet.build([
                                HandSet.build_card('♠A'),
                                HandSet.build_card('♥2'),
                                HandSet.build_card('♦3'),
                                HandSet.build_card('♣4'),
                                HandSet.build_card('♠5')
                              ])

        six_high_straight = HandSet.build([
                                            HandSet.build_card('♠2'),
                                            HandSet.build_card('♥3'),
                                            HandSet.build_card('♦4'),
                                            HandSet.build_card('♣5'),
                                            HandSet.build_card('♠6')
                                          ])

        result = described_class.call(wheel, six_high_straight)
        expect(result).to eq(-1)
      end
    end

    context 'フルハウス同士の比較' do
      it 'より高いスリーカード部分が勝つ' do
        aces_full_of_kings = HandSet.build([
                                             HandSet.build_card('♠A'),
                                             HandSet.build_card('♥A'),
                                             HandSet.build_card('♦A'),
                                             HandSet.build_card('♣K'),
                                             HandSet.build_card('♠K')
                                           ])

        kings_full_of_aces = HandSet.build([
                                             HandSet.build_card('♠K'),
                                             HandSet.build_card('♥K'),
                                             HandSet.build_card('♦K'),
                                             HandSet.build_card('♣A'),
                                             HandSet.build_card('♠A')
                                           ])

        result = described_class.call(aces_full_of_kings, kings_full_of_aces)
        expect(result).to eq(1)
      end
    end

    context 'フォーカード同士の比較' do
      it 'より高いフォーカードが勝つ' do
        four_aces = HandSet.build([
                                    HandSet.build_card('♠A'),
                                    HandSet.build_card('♥A'),
                                    HandSet.build_card('♦A'),
                                    HandSet.build_card('♣A'),
                                    HandSet.build_card('♠K')
                                  ])

        four_kings = HandSet.build([
                                     HandSet.build_card('♠K'),
                                     HandSet.build_card('♥K'),
                                     HandSet.build_card('♦K'),
                                     HandSet.build_card('♣K'),
                                     HandSet.build_card('♠A')
                                   ])

        result = described_class.call(four_aces, four_kings)
        expect(result).to eq(1)
      end
    end

    context '完全に同等の場合' do
      it '同じ手札は0を返す' do
        hand1 = HandSet.build([
                                HandSet.build_card('♠A'),
                                HandSet.build_card('♥K'),
                                HandSet.build_card('♦Q'),
                                HandSet.build_card('♣J'),
                                HandSet.build_card('♠10')
                              ])

        hand2 = HandSet.build([
                                HandSet.build_card('♦A'),
                                HandSet.build_card('♣K'),
                                HandSet.build_card('♠Q'),
                                HandSet.build_card('♥J'),
                                HandSet.build_card('♦10')
                              ])

        result = described_class.call(hand1, hand2)
        expect(result).to eq(0)
      end
    end
  end
end
