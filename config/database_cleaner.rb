require 'database_cleaner'

module DatabaseCleanerConfig
  CLEAN_MODE = :truncation
  CLEAN_OPTIONS = { except: %w(ontology_file_extensions) }

  if defined?(RSpec) && RSpec.respond_to?(:configure)
    RSpec.configure do |config|
      config.use_instantiated_fixtures  = false
      config.use_transactional_fixtures = false

      config.before(:suite) do
        DatabaseCleaner.strategy = CLEAN_MODE, CLEAN_OPTIONS
        DatabaseCleaner.clean
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
    DatabaseCleaner.strategy = CLEAN_MODE, CLEAN_OPTIONS
    DatabaseCleaner.clean

    class ActiveSupport::TestCase

      teardown do
        DatabaseCleaner.clean
      end

    end
  end
end
