class HistoriesReadModel
  def self.load(limit: 10)
    History.order(ended_at: :desc).limit(limit)
  end
end
