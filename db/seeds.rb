# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).

# Clean the database
DatabaseCleaner.clean_with :truncation, except: %w(
  ontology_file_extensions
  file_extension_mime_type_mappings
  proof_statuses
)

# Output seed information iff environment variable VERBOSE_SEEDS is set to 1
ActiveRecord::Base.logger = Logger.new($stdout) if ENV["VERBOSE_SEEDS"] == '1'

# Run background jobs inline
require 'sidekiq/testing'
Sidekiq::Testing.inline!

# Purge data directory
FileUtils.rm_rf(Dir.glob(Ontohub::Application.config.git_root.join('*')))
FileUtils.rm_rf(Dir.glob(Ontohub::Application.config.git_daemon_path.join('*')))
FileUtils.rm_rf(Dir.glob(Ontohub::Application.config.commits_path.join('*')))

# Include every .rb file inside db/seeds directory.
Dir["#{Rails.root}/db/seeds/*.rb"].sort.each do |path|
  puts File.basename path
  require path
end

