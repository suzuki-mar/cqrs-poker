class GameStateDomain
  def initialize(record)
    @record = record
  end
  
  def save_current_state
    @record.save
  end
    
end 