require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'ユーザー名は必須であること' do
      user = User.new(username: nil)
      expect(user).not_to be_valid
    end
  end
end 