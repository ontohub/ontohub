require 'spec_helper'

describe OntologiesController do
  it do
    should route(:post, 'repositories/repopath/ontologies/retry_failed').to(
      repository_id: 'repopath', action: :retry_failed)
  end

  it do
    should route(:post, 'repositories/repopath/ontologies/id/retry_failed').to(
      repository_id: 'repopath', action: :retry_failed, id: 'id')
  end

  it do
    should route(:get, 'repositories/repopath/ontologies').to(
      controller: :ontologies, action: :index,
      repository_id: 'repopath')
  end

  it do
    should route(:get, 'repositories/repopath/ontologies/id/edit').to(
      controller: :ontologies, action: :edit,
      repository_id: 'repopath', id: 'id')
  end

  it do
    should route(:get, 'repositories/repopath/ontologies/id').to(
      controller: :ontologies, action: :show,
      repository_id: 'repopath', id: 'id')
  end

  it do
    should route(:put, 'repositories/repopath/ontologies/id').to(
      controller: :ontologies, action: :update,
      repository_id: 'repopath', id: 'id')
  end

  it do
    should route(:delete, 'repositories/repopath/ontologies/id').to(
      controller: :ontologies, action: :destroy,
      repository_id: 'repopath', id: 'id')
  end
end
