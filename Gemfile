source 'https://rubygems.org'

gem 'rails', '~> 3.2.2'
gem 'pg'
gem 'foreigner'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'compass',      '~> 0.12.1'
  gem 'jquery-ui-rails'
  gem 'momentjs-rails'

  gem 'therubyracer'
  gem 'uglifier', '>= 1.0.3'
end

gem 'haml-rails'
gem 'jquery-rails'

# Fancy Forms
gem 'formtastic', '~> 2.1.1'

# Inherited Resources
gem 'inherited_resources'
gem 'has_scope'

# XML Parser
gem 'nokogiri', '~> 1.5.0'

# Authentication
gem 'devise', '~> 2.0'

# Authorization
gem 'cancan', '~> 1.6.7'

# Pagination
gem 'kaminari'

# Strip spaces in attributes
gem "strip_attributes", "~> 1.0"

# Manage uploads
gem 'carrierwave', "~> 0.6.1"

# Async jobs
gem 'resque'

# Search engine
gem 'sunspot_rails', :git => 'git://github.com/digineo/sunspot.git'

gem "faker", "~> 1.0"

group :test do
  gem 'mocha'
  gem 'shoulda'
  gem 'shoulda-matchers'
  gem 'shoulda-context'
  gem "shoulda_routing_macros", "~> 0.1.2"
  gem "factory_girl_rails", "~> 1.7.0"
end

group :development do
  gem 'capistrano'
  # pre-packaged Solr distribution for use in development
  gem 'sunspot_solr', :git => 'git://github.com/digineo/sunspot.git'
end

group :production do
  gem 'god'
  gem 'newrelic_rpm'
end
