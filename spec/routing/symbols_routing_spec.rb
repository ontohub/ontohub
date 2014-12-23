require 'spec_helper'

describe SymbolsController do
  it do
    should route(:get, "/repositories/path/ontologies/id/symbols").to(
      controller: :symbols,
      action: :index,
      repository_id: 'path',
      ontology_id: 'id'
    )
  end
end
