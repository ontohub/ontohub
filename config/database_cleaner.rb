require 'database_cleaner'

module DatabaseCleanerConfig
  CLEAN_MODE = :transaction
  INITIAL_CLEAN_MODE = :truncation
  INITIAL_CLEAN_OPTIONS = {
    except: %w(
      ontology_file_extensions
      file_extension_mime_type_mappings
      proof_statuses
    ),
  }

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

        # Remove repositories and other data created in a test
        %w(data test).each do |d|
          dir = Rails.root.join('tmp', d)
          dir.rmtree if dir.exist?
        end
      end
    end
  end
end
