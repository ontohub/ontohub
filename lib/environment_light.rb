require 'pathname'

# Set up Rails configuration
Rails = Struct.new(:env,:root,:logger).new
Rails.env  = ENV['RAILS_ENV'] || 'production'
Rails.root = Pathname.new(File.dirname(__FILE__) << "/..")

# Load application settings
require File.expand_path(
  File.join(File.dirname(__FILE__), "../config/initializers/rails_config"))
Settings = RailsConfig.load_files ["settings.yml","settings.local.yml", "settings/#{Rails.env}.yml"].map{|f| "#{Rails.root}/config/#{f}" }
