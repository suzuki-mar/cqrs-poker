namespace :game do
  desc 'ポーカーゲームを開始する'
  task start: :environment do
    StartGameUseCase.new.execute
  end
end
