require 'spec_helper'

describe FilesController do
  before do
    Repository.stub(:find_by_path) { true }
    RepositoryFile.stub(:find_with_path) { true }
  end

  after do
    Repository.unstub(:find_by_path)
    RepositoryFile.unstub(:find_with_path)
  end
  # FIXME some/path must exist in repository
  #it { should     route(:get,  'repopath/some/path'               ).to(repository_id: 'repopath', action: :files, path: 'some/path') }

  it { should     route(:get,  'repopath'                         ).to(repository_id: 'repopath', action: :show ) }
  it { should     route(:get,  'repositories/repopath/files/new'  ).to(repository_id: 'repopath', action: :new ) }
  it { should     route(:post, 'repositories/repopath/files'      ).to(repository_id: 'repopath', action: :create ) }
  it { should     route(:get,  'repositories/repopath/12ab/action' ).to(repository_id: 'repopath', action: :action, ref: '12ab' ) }
  it { should     route(:get,  'repositories/repopath/12ab/files/some/path' ).to(repository_id: 'repopath', action: :show, ref: '12ab', path: 'some/path' ) }

  it { should     route(:get,  'repositories/repopath/master/history'      ).to(repository_id: 'repopath', action: :history, ref: 'master' ) }
end
