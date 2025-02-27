require 'rails_helper'

RSpec.describe GameStateDomain do
  
  describe '#save_current_state' do
    let(:record) { build(:game_state) }
    let(:game_state_domain) { GameStateDomain.new(record) }
    subject { game_state_domain.save_current_state }
    
    context '正常系' do
      it 'レコードの状態が保存される' do        
        record.current_turn = 2
        
        subject
                
        saved_record = ::GameState.find(record.id)
        expect(saved_record.current_turn).to eq(2)
      end
    end

    context '異常系' do
      it '不正なデータの場合は保存に失敗する' do        
        record.current_turn = 999999  
                
        expect(subject).to be_falsey
      end
    end
  end
    
end 