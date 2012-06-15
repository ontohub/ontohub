require "test_helper"
require "capybara/rails"
 
module ActionController
  class IntegrationTest
    include Capybara::DSL
  end
end