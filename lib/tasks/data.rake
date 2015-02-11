namespace :data do
  namespace :migrate do
    desc 'Migrate data migrations asynchronously with Sidekiq'
    task :async => :environment do
      DataMigrationWorker.perform_async
    end
  end
end
