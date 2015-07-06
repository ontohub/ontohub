require 'spec_helper'

describe 'FilesControllerRouting' do
  before do
    allow(Repository).to receive(:find_by_path).and_return(true)
    allow(RepositoryFile).to receive(:find_with_path).and_return(true)
  end

  it { should     route(:get,  'repopath'                                   ).to(repository_id: 'repopath', controller: :files, action: :show ) }
  it { should     route(:get,  'repopath/some/path'                         ).to(repository_id: 'repopath', controller: :files, action: :show, path: 'some/path') }
  it { should     route(:get,  'repositories/repopath/files/new'            ).to(repository_id: 'repopath', controller: :files, action: :new ) }
  it { should     route(:post, 'repositories/repopath/files'                ).to(repository_id: 'repopath', controller: :files, action: :create ) }
  it { should     route(:get,  'repositories/repopath/12ab/action'          ).to(repository_id: 'repopath', controller: :files, action: :action, ref: '12ab' ) }
  it { should     route(:get,  'repositories/repopath/12ab/files/some/path' ).to(repository_id: 'repopath', controller: :files, action: :show, ref: '12ab', path: 'some/path' ) }
  it { should     route(:delete, 'repopath/some/path'                       ).to(repository_id: 'repopath', controller: :files, action: :destroy, path: 'some/path') }
end
