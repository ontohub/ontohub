namespace :test do

  # We want to purge our database our own way, without deleting everything
  Rake::Task['db:test:purge'].overwrite do
    Rails.env = 'test'
    Rake::Task['db:redis:clean'].invoke
    Rake::Task['db:migrate:clean'].invoke
  end

end
