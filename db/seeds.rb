# This file should contain all the record creation needed to seed the database
# with its default values. The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).

# Clean the database
DatabaseCleaner.clean_with :truncation, except: %w(ontology_file_extensions)

# Output seed information iff environment variable VERBOSE_SEEDS is set to 1
ActiveRecord::Base.logger = Logger.new($stdout) if ENV["VERBOSE_SEEDS"] == '1'

# Run background jobs inline
require 'sidekiq/testing'
Sidekiq::Testing.inline!

# Purge data directory
data_root = Ontohub::Application.config.data_root
data_root.rmtree if data_root.exist?

# Include every .rb file inside db/seeds directory.
Dir["#{Rails.root}/db/seeds/*.rb"].sort.each do |path|
  puts File.basename path
  require path
end

