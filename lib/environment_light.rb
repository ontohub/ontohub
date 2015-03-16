require 'pathname'

# Set up Rails configuration
rails_env = ENV['RAILS_ENV'] || 'production'
rails_root = Pathname.new(File.dirname(__FILE__) << "/..")

# Load Bundler
ENV['BUNDLE_GEMFILE'] = rails_root.join('Gemfile').to_s
require 'rubygems'
require 'bundler/setup'

# Load application settings
require rails_root.join('config/initializers/rails_config.rb')
# only load basic files, NOT the auxiliaries like hets.yml
settings_files = RailsConfig.setting_files(rails_root.join('config'), rails_env)
abs_settings_files = settings_files.map { |f| rails_root.join('config', f) }
Settings = RailsConfig.load_files(abs_settings_files)

Rails = Struct.new(:env, :root, :logger).new
Rails.env  = rails_env
Rails.root = rails_root
