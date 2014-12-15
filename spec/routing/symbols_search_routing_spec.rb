require 'spec_helper'

describe SymbolsSearchController do
  it do
    should route(:get, 'symbols_search').to(
      controller: :symbols_search, action: :index)
  end
end
