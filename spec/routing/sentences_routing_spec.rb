require 'spec_helper'

describe SentencesController do
  it do
    should route(:get, "/repositories/path/ontologies/id/sentences").to(
      controller: :sentences,
      action: :index,
      repository_id: 'path',
      ontology_id: 'id')
  end
end
