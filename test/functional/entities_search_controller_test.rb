require 'test_helper'

class EntitiesSearchControllerTest < ActionController::TestCase

  should route(:get, 'entities_search').to(controller: :entities_search, action: :index)

end
