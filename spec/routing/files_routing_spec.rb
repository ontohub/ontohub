require 'spec_helper'

describe 'FilesControllerRouting' do
  before do
    allow(Repository).to receive(:find_by_path).and_return(true)
    allow(RepositoryFile).to receive(:find_with_path).and_return(true)
  end

  it { expect(subject).to     route(:get,  'repopath'                                   ).to(repository_id: 'repopath', controller: :files, action: :show ) }
  it { expect(subject).to     route(:get,  'repopath/some/path'                         ).to(repository_id: 'repopath', controller: :files, action: :show, path: 'some/path') }
  it { expect(subject).to     route(:get,  'repositories/repopath/files/new'            ).to(repository_id: 'repopath', controller: :files, action: :new ) }
  it { expect(subject).to     route(:post, 'repositories/repopath/files'                ).to(repository_id: 'repopath', controller: :files, action: :create ) }
  it { expect(subject).to     route(:get,  'repositories/repopath/12ab/action'          ).to(repository_id: 'repopath', controller: :files, action: :action, ref: '12ab' ) }
  it { expect(subject).to     route(:get,  'repositories/repopath/12ab/files/some/path' ).to(repository_id: 'repopath', controller: :files, action: :show, ref: '12ab', path: 'some/path' ) }
  it { expect(subject).to     route(:delete, 'repopath/some/path'                       ).to(repository_id: 'repopath', controller: :files, action: :destroy, path: 'some/path') }
end
