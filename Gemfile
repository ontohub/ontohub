source 'https://rubygems.org'

gem 'rails', '~> 3.2.13'
gem 'rack-protection'
gem 'secure_headers'

gem 'pg'
gem 'foreigner'

gem 'rdf'
gem 'rdf-rdfxml'
gem 'rdf-n3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'bootstrap-sass', "~> 2.3.2"
  gem 'coffee-rails', '~> 3.2.1'
  gem 'compass',      '~> 0.12.1'
  gem 'font_awesome'
  gem 'jquery-rails'
  gem 'jquery-ui-rails'
  gem 'momentjs-rails'
  gem 'd3_rails'
  gem 'therubyracer'
  gem 'uglifier', '>= 1.0.3'
end

gem 'haml-rails'

# Project configuration
gem 'rails_config'

# Fancy Forms
gem 'simple_form'

# Inherited Resources
gem 'inherited_resources', '~> 1.4.0'
gem 'has_scope'

# XML Parser
gem 'nokogiri', '~> 1.6'

# Authentication
gem 'devise', '~> 2.0'

# Authorization
gem 'cancan', '~> 1.6.7'

# Pagination
gem 'kaminari'

# Strip spaces in attributes
gem "strip_attributes", "~> 1.0"

# For distributed ontologies
gem 'acts_as_tree'

# Manage uploads
gem 'carrierwave', "~> 0.8.0"

# HTTP Client
gem "rest-client"

# Async jobs
gem 'resque'
gem 'redis-namespace'

# Search engine
gem 'sunspot_rails', :git => 'git://github.com/digineo/sunspot.git'
gem 'progress_bar'

# Graph visualization
gem 'ruby-graphviz', "~> 1.0.8"

# Fake-inputs for tests and seeds
gem "faker", "~> 1.1.2"

group :test do
  gem 'mocha', require: 'mocha/setup'
  gem 'shoulda'
  gem "shoulda_routing_macros", "~> 0.1.2"
  gem "factory_girl_rails"
  
  # Required for integration tests
  gem "capybara"
  gem "capybara-webkit"
  gem 'database_cleaner'
  gem "launchy"
  
  # Recording of HTTP Requests
  gem "vcr"
  gem "webmock", '~> 1.9.0'
end

group :development do
  gem 'capistrano'
  gem 'rvm-capistrano'
  # pre-packaged Solr distribution for use in development
  gem 'sunspot_solr', :git => 'git://github.com/digineo/sunspot.git'
  gem "rails-erd"
  gem 'quiet_assets'
end

group :production do
  gem 'god'
  gem 'exception_notification', '~> 2.6.1'
end

group :documentation do
  gem 'yard'
  gem 'redcarpet'
end
