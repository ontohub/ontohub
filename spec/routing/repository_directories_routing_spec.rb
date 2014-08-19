require 'spec_helper'

describe 'RepositoryDirectories Routing' do
  it { should route(:get, 'repositories/repopath/repository_directories/new').
    to(controller: 'repository_directories', action: :new, repository_id: 'repopath' ) }
  it { should route(:post, 'repositories/repopath/repository_directories').
    to(controller: 'repository_directories', action: :create, repository_id: 'repopath' ) }
end
