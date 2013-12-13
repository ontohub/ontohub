require 'database_cleaner'

RSpec.configure do |config|
  config.use_instantiated_fixtures  = false
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean

    # Remove repositories
    dir = Rails.root.join("tmp","repositories")
    dir.rmtree if dir.exist?
  end
end
