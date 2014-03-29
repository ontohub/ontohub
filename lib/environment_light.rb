require 'pathname'

# Set up Rails configuration
Rails = Struct.new(:env,:root,:logger).new
Rails.env  = ENV['RAILS_ENV'] || 'production'
Rails.root = Pathname.new(File.dirname(__FILE__) << "/..")

# Load Bundler
ENV['BUNDLE_GEMFILE'] = Rails.root.join('Gemfile').to_s
require 'rubygems'
require 'bundler/setup'

# Load application settings
require File.expand_path("../../config/initializers/rails_config", __FILE__)
Settings = RailsConfig.load_files ["settings.yml","settings.local.yml", "settings/#{Rails.env}.yml"].map{|f| "#{Rails.root}/config/#{f}" }
