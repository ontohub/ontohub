class DataMigrationWorker < BaseWorker
  sidekiq_options queue: 'default'

  def perform
    Subprocess.run('bundle', 'exec', 'rake', 'data:migrate',
      'RAILS_ENV' => Rails.env )
  end
end
