require 'spec_helper'

describe CommentsController do

  it { should route(:get,  "/repositories/repository_id/ontologies/ontology_id/comments").
    to(action: :index, ontology_id: 'ontology_id', repository_id: 'repository_id') }
  it { should route(:post, "/repositories/repository_id/ontologies/ontology_id/comments").
    to(action: :create, ontology_id: 'ontology_id', repository_id: 'repository_id') }

end
