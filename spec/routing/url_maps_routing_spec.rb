require 'spec_helper'

describe UrlMapsController do
  it { should     route(:get,    'repositories/repopath/url_maps'       ).to(repository_id: 'repopath',        action: :index   ) }
  it { should     route(:post,   'repositories/repopath/url_maps'       ).to(repository_id: 'repopath',        action: :create  ) }
  it { should     route(:get,    'repositories/repopath/url_maps/new'   ).to(repository_id: 'repopath',        action: :new     ) }
  it { should     route(:get,    'repositories/repopath/url_maps/2/edit').to(repository_id: 'repopath', id: 2, action: :edit    ) }
  it { should     route(:put,    'repositories/repopath/url_maps/2'     ).to(repository_id: 'repopath', id: 2, action: :update  ) }
  it { should     route(:delete, 'repositories/repopath/url_maps/2'     ).to(repository_id: 'repopath', id: 2, action: :destroy ) }
end
