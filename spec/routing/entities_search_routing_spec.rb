require 'spec_helper'

describe EntitiesSearchController do
  it do
    should route(:get, 'entities_search').to(
      controller: :entities_search, action: :index)
  end
end
