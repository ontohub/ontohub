require 'spec_helper'

describe 'RepositoryDirectories Routing' do
  it { should route(:post, 'repositories/repopath/repository_directories').
    to(controller: 'repository_directories', action: :create, repository_id: 'repopath' ) }
end
