require 'spec_helper'

describe FilesController do
  it { should     route(:get,  'repopath/some/path'               ).to(repository_id: 'repopath', action: :files, path: 'some/path') }
  it { should     route(:get,  'repositories/repopath/files/new'  ).to(repository_id: 'repopath', action: :new ) }
  it { should     route(:post, 'repositories/repopath/files'      ).to(repository_id: 'repopath', action: :create ) }
  it { should     route(:get,  'repositories/repopath/oid/action' ).to(repository_id: 'repopath', action: :action, oid: 'oid' ) }
end
