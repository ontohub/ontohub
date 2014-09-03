require 'database_cleaner'

module DatabaseCleanerConfig
  CLEAN_MODE = :transaction
  INITIAL_CLEAN_MODE = :truncation
  INITIAL_CLEAN_OPTIONS = { except: %w(ontology_file_extensions) }

  if defined?(RSpec) && RSpec.respond_to?(:configure)
    RSpec.configure do |config|
      config.use_instantiated_fixtures  = false
      config.use_transactional_fixtures = false

      config.before(:suite) do
        DatabaseCleaner.strategy = INITIAL_CLEAN_MODE, INITIAL_CLEAN_OPTIONS
        DatabaseCleaner.clean
        DatabaseCleaner.strategy = CLEAN_MODE
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
  end

  if defined? ActiveSupport::TestCase
    # Set strategy and clean once at load time
    DatabaseCleaner.strategy = INITIAL_CLEAN_MODE, INITIAL_CLEAN_OPTIONS
    DatabaseCleaner.clean
    DatabaseCleaner.strategy = CLEAN_MODE

    class ActiveSupport::TestCase

      class_attribute :use_transactional_fixtures
      class_attribute :use_instantiated_fixtures

      self.use_transactional_fixtures = false
      self.use_instantiated_fixtures  = false

      setup do
        DatabaseCleaner.start
      end

      teardown do
        DatabaseCleaner.clean
      end

    end
  end
end
