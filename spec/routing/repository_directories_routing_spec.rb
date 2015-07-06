require 'spec_helper'

describe 'RepositoryDirectories Routing' do
  it { expect(subject).to route(:post, 'repositories/repopath/repository_directories').
    to(controller: 'repository_directories', action: :create, repository_id: 'repopath' ) }
end
