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
# only load basic files, NOT the auxiliaries like hets.yml
settings_files = RailsConfig.setting_files(Rails.root.join('config'), Rails.env)
abs_settings_files = settings_files.map { |f| Rails.root.join('config', f) }
Settings = RailsConfig.load_files(abs_settings_files)
