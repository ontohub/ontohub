require 'pathname'

# Set up Rails configuration
Rails = Struct.new(:env,:root,:logger).new
Rails.env  = ENV['RAILS_ENV'] || 'production'
Rails.root = Pathname.new(File.dirname(__FILE__) << '/..')

# Load Bundler
ENV['BUNDLE_GEMFILE'] = Rails.root.join('Gemfile').to_s
require 'rubygems'
require 'bundler/setup'

# Load application settings
require Rails.root.join('config/initializers/rails_config.rb')
Settings = RailsConfig.load_files([
    'settings.yml',
    "settings/#{Rails.env}.yml",
    "environments/#{Rails.env}.yml",
    'settings.local.yml',
    "settings.#{Rails.env}.local.yml",
    "environments/#{Rails.env}.local.yml",
    'hets.yml'
  ].map { |f| Rails.root.join('config', f) })
