require 'spec_helper'

describe OopsRequestsController do
  it do
    expect(subject).to route(:get,
      '/repositories/1/ontologies/12/versions/45/oops_request').to(
      controller: :oops_requests, action: :show,
      repository_id: '1', ontology_id: '12', ontology_version_id: '45')
  end

  it do
    expect(subject).to route(:post,
      '/repositories/1/ontologies/12/versions/45/oops_request').to(
      controller: :oops_requests, action: :create,
      repository_id: '1', ontology_id: '12', ontology_version_id: '45')
  end
end
