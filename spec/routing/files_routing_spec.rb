require 'spec_helper'

describe FilesController do
  # FIXME some/path must exist in repository
  #it { should     route(:get,  'repopath/some/path'               ).to(repository_id: 'repopath', action: :files, path: 'some/path') }

  it { should     route(:get,  'repopath'                         ).to(repository_id: 'repopath', action: :files ) }
  it { should     route(:get,  'repositories/repopath/files/new'  ).to(repository_id: 'repopath', action: :new ) }
  it { should     route(:post, 'repositories/repopath/files'      ).to(repository_id: 'repopath', action: :create ) }
  it { should     route(:get,  'repositories/repopath/12ab/action' ).to(repository_id: 'repopath', action: :action, ref: '12ab' ) }
  it { should     route(:get,  'repositories/repopath/12ab/files/some/path' ).to(repository_id: 'repopath', action: :files, ref: '12ab', path: 'some/path' ) }

  it { should     route(:get,  'repositories/repopath/master/history'      ).to(repository_id: 'repopath', action: :history, ref: 'master' ) }
end
