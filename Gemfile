source 'https://rubygems.org'

gem 'rails', '~> 3.2.19'
gem 'rack-protection', '~> 1.5.3'
gem 'secure_headers', '~> 1.2.0'

gem 'pry-rails', '~> 0.3.2'

gem 'pg', '~> 0.17.1'
gem 'foreigner', '~> 1.6.1'

gem 'rdf', '~> 1.1.4.3'
gem 'rdf-rdfxml', '~> 1.1.0.1'
gem 'rdf-n3', '~> 1.1.1'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'jstree-rails', :git => 'git://github.com/tristanm/jstree-rails.git'
  gem 'sass-rails',     '~> 3.2.3'
  gem 'bootstrap-sass', '~> 3.0.0'
  gem 'coffee-rails',   '~> 3.2.1'
  gem 'compass',        '~> 0.12.1'
  gem 'font_awesome', '~> 3.101.0'
  gem 'jquery-rails', '~> 3.1.1'
  gem 'jquery-ui-rails', '~> 5.0.0'
  gem 'momentjs-rails', '~> 2.8.1'
  gem 'd3_rails', '~> 3.4.10'
  gem 'therubyracer', '~> 0.12.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'handlebars_assets', '~> 0.14.1'
  gem 'hamlbars', '~> 2.1.1'
  gem 'underscore-rails', '~> 1.6.0'
end

gem 'haml-rails', '~> 0.4'

# Project configuration
# Version above and including 0.4 requires rails
# which is a problem in git-hooks
gem 'rails_config', '~> 0.3.0'

# Fancy Forms
gem 'simple_form', '~> 2.1.1'

# Inherited Resources
gem 'inherited_resources', '~> 1.4.0'
gem 'has_scope', '~> 0.6.0.rc'

# JSON views
gem 'rabl', '~> 0.10.1'

# XML Parser
gem 'nokogiri', '~> 1.6.3.1'

# Authentication
gem 'devise', '~> 3.2.4'

# Authorization
gem 'cancan', '~> 1.6.7'

# Pagination
gem 'kaminari', '~> 0.16.1'

# Strip spaces in attributes
gem "strip_attributes", "~> 1.0"

# For distributed ontologies
gem 'acts_as_tree', '~> 2.0.0'

# HTTP Client
gem "rest-client", '~> 1.7.2'

# Background-Jobs
gem 'sidekiq', '~> 3.2.1'
gem 'sidetiq', '~> 0.6.1'
gem 'sidekiq-failures', '~> 0.4.3'
gem 'sinatra', '~> 1.4.5', require: false, group: [:development, :production]

# Search engine
gem 'sunspot_rails', :git => 'git://github.com/digineo/sunspot.git'
gem 'progress_bar', '~> 1.0.2'

# Graph visualization
gem 'ruby-graphviz', "~> 1.0.8"

# Fake-inputs for tests and seeds
gem "faker", "~> 1.2"

# Git
gem 'rugged', '0.21.0'
gem 'codemirror-rails', github: 'llwt/codemirror-rails'
gem 'js-routes', '~> 0.9.8'

# Ancestry enabling tree structure in category model
# gem 'ancestry'

# Use dagnabit to model categories
gem 'dagnabit', '~> 3.0.1'

group :test do
  gem 'mocha', '~> 1.1.0', require: false
  gem 'shoulda', '~> 3.5.0'
  gem "shoulda_routing_macros", "~> 0.1.2"
  gem "factory_girl_rails", '~> 4.4.1'

  # Required for integration tests
  gem "capybara", '~> 2.4.1'
  gem "capybara-webkit", '~> 1.1.0'
  gem "launchy", '~> 2.4.2'

  # Recording of HTTP Requests
  gem "vcr", '~> 2.9.2'
  gem "webmock", '~> 1.9.0'

  gem 'cucumber-rails', '~> 1.4', require: false
  # Code Coverage Analysis
  gem 'simplecov', '~> 0.9.0', require: false

  # Writing test ontologies
  gem 'ontology-united', github: '0robustus1/ontology-united'
end

group :development do
  # pre-packaged Solr distribution for use in development
  gem 'sunspot_solr', :git => 'git://github.com/digineo/sunspot.git'
  gem "rails-erd", '~> 1.1.0'
  gem 'quiet_assets', '~> 1.0.3'
  gem 'invoker', '~> 1.2.0'
end

group :development, :test do
  gem 'database_cleaner', '~> 1.3.0'
  gem 'rspec-rails', '~> 2.0'
  gem 'better_errors', '~> 1.1.0'
  gem 'binding_of_caller', '~> 0.7.2'
end

group :production do
  gem 'god', '~> 0.13.4'
  gem 'exception_notification', '~> 4.0.1'
end

group :deployment do
  gem 'capistrano', '~> 3.1.0'
  gem 'capistrano-rails', '~> 1.1.1'
  gem 'capistrano-rvm', '~> 0.1.1'
end

group :documentation do
  gem 'yard', '~> 0.8.7.4'
  gem 'redcarpet', '~> 3.1.2'
end
