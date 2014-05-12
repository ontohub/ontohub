require "test_helper"
require "capybara/rails"

# Transactional fixtures do not work with Selenium tests, because Capybara
# uses a separate server thread, which the transactions would be hidden
# from. We hence use DatabaseCleaner to truncate our test database.
DatabaseCleaner.strategy = :truncation

# use webkit as driver for capybara
Capybara.current_driver = :webkit
Capybara.javascript_driver = :webkit

class ActionController::IntegrationTest

  include Warden::Test::Helpers

  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  # Stop ActiveRecord from wrapping tests in transactions
  self.use_transactional_fixtures = false

  teardown do
    DatabaseCleaner.clean       # Truncate the database
    Capybara.reset_sessions!    # Forget the (simulated) browser state
  end

end
