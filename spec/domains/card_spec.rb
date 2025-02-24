require 'rails_helper'

RSpec.describe Card do
  describe '#valid?' do
    subject { Card.new(card_str).valid? }

    context '正常な値の場合' do
      context 'スートとランクが正しい場合' do
        context '数字の場合' do
          let(:card) { Faker::Card.card_with_rank(Faker::Card.number_rank) }
          it { expect(card.valid?).to be true }
        end

        context '絵札の場合' do
          let(:card) { Faker::Card.card_with_rank(Faker::Card.face_rank) }
          it { expect(card.valid?).to be true }
        end
      end
    end

    context '不正な値の場合' do
      let(:card) { Faker::Card.invalid_card }
      it { expect(card.valid?).to be false }
    end
  end
end 