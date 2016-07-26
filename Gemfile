source 'https://rubygems.org'

gem 'rails', '~> 3.2.22'
gem 'rack-protection', '~> 1.5.3'
gem 'secure_headers', '~> 3.4.0'

gem 'pry-rails', '~> 0.3.2'

gem 'pg', '~> 0.18.1'
gem 'foreigner', '~> 1.7.2'

gem 'rdf', '~> 2.0.2'
gem 'rdf-n3', '~> 2.0.0'
gem 'rdf-rdfxml', '~> 2.0.0'

# As soon as the pull request https://github.com/dv/redis-semaphore/pull/46 is
# merged and a new release is out, use the upstream gem again.
gem 'redis-semaphore', github: 'eugenk/redis-semaphore', ref: '45-recognize_the_lock_state_of_multiple_semaphores_using_the_same_key'
# Used for testing our locking mechanism Semaphore:
gem 'fork_break', '~> 0.1.4'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'jstree-rails', github: 'tristanm/jstree-rails'
  # sass-rails >= 4.0 is not compativle to rails 3
  gem 'sass-rails',     '~> 3.2.6'
  # bootstrap-sass >= 3.3.6 is not compatible to rails 3
  gem 'bootstrap-sass', '~> 3.3.5.1'
  # coffee-rails > 3.2 is not compatible to rails 3
  gem 'coffee-rails',   '~> 3.2.2'
  gem 'compass',        '~> 1.0.3'
  gem 'font-awesome-sass', '~> 4.6.2'
  # jquery-rails > 3.1 is not compatible to rails 3
  gem 'jquery-rails', '~> 3.1.3'
  gem 'jquery-ui-rails', '~> 5.0.5'
  gem 'momentjs-rails', '~> 2.11.0'
  gem 'd3_rails', '~> 4.1.1'
  gem 'therubyracer', '~> 0.12.1'
  gem 'uglifier', '>= 1.0.3'
  # handlebars_assets >= 0.23.0 is not compatible to rails 3
  gem 'handlebars_assets', '~> 0.22.0'
  gem 'hamlbars', '~> 2.1.1'
  gem 'underscore-rails', '~> 1.8.2'
  gem 'bootstrap-select-rails', '~> 1.6.3'
end

# Newer versions than 0.4 are not compatible to rails 3.2
gem 'haml-rails', '~> 0.4'

# Project configuration
# The specified commit is from a fork and allows to overwrite arrays.
# It has been pull-requested:
# https://github.com/railsconfig/rails_config/pull/103
gem 'rails_config', github: 'dtaniwaki/rails_config', ref: 'merge-array-option'

# Provides  correct indefinite article
gem 'indefinite_article', '~> 0.2.0'

# Fancy Forms
# simple_form >= 3.0 is not compatible to rails 3
gem 'simple_form', '~> 2.1'

# Inherited Resources
gem 'inherited_resources', '~> 1.4.1'
# has_scope => 0.7.0 dies not support Rails 3.2 and 4.0
gem 'has_scope', '~> 0.6.0.rc'

# JSON views
# active_model_serializers >= 0.10.0 is not compatible to rails 3
gem 'active_model_serializers', '~> 0.9.3'

# JSON Parser
gem 'json-stream', '~> 0.2.1'

# XML Parser
gem 'nokogiri', '~> 1.6.8'

# Authentication
# devise => 4.0.0 does not support Rails 3.2 and Rails 4.0
gem 'devise', '~> 3.5.2'

# Authorization
gem 'cancan', '~> 1.6.7'

# Pagination
gem 'kaminari', '~> 0.17.0'

# Strip spaces in attributes
gem "strip_attributes", "~> 1.0"

# For distributed ontologies
gem 'acts_as_tree', '~> 2.4.0'

# HTTP Client
gem "rest-client", '~> 2.0.0'

# Background-Jobs
gem 'sidekiq', '~> 3.5.3'
# Originally, sidetiq is not compatible to celluloid 0.17.2. This fork fixes it.
# The ref is given to ensure that no other (possibly breaking) changes are taken.
gem 'sidetiq', github: 'PaulMest/sidetiq', ref: 'd88f9e483affcbadbd9e8b98b4a0a9518933887a'
gem 'sidekiq-failures', '~> 0.4.5'
gem 'sidekiq-retries', '~> 0.4.0'
gem 'sidekiq-status', '~> 0.6.0'
gem 'sinatra', '~> 1.4.5', require: false, group: [:development, :production]

# Search engine
gem 'progress_bar', '~> 1.0.2'
gem 'elasticsearch', '~> 2.0.0'
gem 'elasticsearch-extensions', '~> 0.0.15'
gem 'elasticsearch-model', '~> 0.1.4'
gem 'elasticsearch-rails', '~> 0.1.4'

# Graph visualization
gem 'ruby-graphviz', "~> 1.2.2"

# Fake-inputs for tests and seeds
gem "faker", "~> 1.6.1"

# Git
gem 'rugged', '~> 0.24.0'
gem 'codemirror-rails', github: 'llwt/codemirror-rails'

# API
gem 'specroutes', github: '0robustus1/specroutes'

# Use dagnabit to model categories
# Newer versions than 3.0.x are not compatible to rails 3.2
gem 'dagnabit', '~> 3.0.1'

# Migrate data in separate tasks
gem 'data_migrate', '~> 1.2.0'

# Multi Table Inheritance. For Rails 4, mirgrate to active_record-acts_as.
gem 'acts_as_relation', '~> 0.1.3'

# Clean the database - especially needed in the seeds
gem 'database_cleaner', '~> 1.5.1'


# For unknown reasons, activesupport-3.2.22.2 requires test-unit, even in
# production mode.
gem 'test-unit', '~> 3.0'
group :test do
  gem 'mocha', '~> 1.1.0', require: false
  gem 'shoulda', '~> 3.5.0'
  gem "shoulda_routing_macros", "~> 0.1.2"
  gem 'rspec-activemodel-mocks', '~> 1.0.1'
  # rspec-its >= 1.1 depends on rspec 3
  gem 'rspec-its', '~> 1.0.1'
  gem "factory_girl_rails", '~> 4.7.0'

  # Required for integration tests
  gem 'capybara', '~> 2.5.0'
  gem 'poltergeist', '~> 1.10.0'
  gem 'launchy', '~> 2.4.3'

  gem 'cucumber-rails', '~> 1.4.2', require: false
  # Versions >= 2.0 are not supported by our formatter.
  # This is a dependency of cucumber-rails. We need to limit the version to 1.x
  gem 'cucumber', '~> 1.3', require: false

  # Code Coverage Analysis
  gem 'simplecov', '~> 0.12.0', require: false

  # So we can validate against json-schemas
  gem 'json-schema', '~> 2.6.0'

  # Writing test ontologies
  gem 'ontology-united', github: '0robustus1/ontology-united'
end

group :development do
  gem "rails-erd", '~> 1.4.2'
  gem 'quiet_assets', '~> 1.1.0'
  gem 'invoker', '~> 1.3.2'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.0'
  gem 'better_errors', '~> 2.1.1'
  gem 'binding_of_caller', '~> 0.7.2'
  # i18n-tasks >= 0.9.0 is not compatible to rails 3/rdf
  gem 'i18n-tasks', '~> 0.8.3'
  gem 'pry-byebug', '~> 3.4.0'
  gem 'pry-stack_explorer', '~> 0.4.9.2'
  gem 'awesome_print', '~> 1.6.1'

  # Recording of HTTP Requests
  gem "vcr", '~> 3.0.0', require: false
  gem "webmock", '~> 2.1.0'
end

group :production do
  # puma is __the only exception__ for which we don't specify a version.
  gem 'puma'
  gem 'eye', '~> 0.8'
  gem 'puma_worker_killer', '~> 0.0.6'
  # exception_notification >= 4.2.0 is not compatible to rails 3
  gem 'exception_notification', '~> 4.1.0'
end

group :deployment do
  gem 'capistrano', '~> 3.5.0'
  gem 'capistrano-rails', '~> 1.1.1'
  gem 'capistrano-rvm', '~> 0.1.1'
end

group :documentation do
  gem 'yard', '~> 0.9.5'
  gem 'redcarpet', '~> 3.3.2'
end
