require 'spec_helper'

describe UrlMapsController do
  it { expect(subject).to     route(:get,    'repositories/repopath/url_maps'       ).to(repository_id: 'repopath',        action: :index   ) }
  it { expect(subject).to     route(:post,   'repositories/repopath/url_maps'       ).to(repository_id: 'repopath',        action: :create  ) }
  it { expect(subject).to     route(:get,    'repositories/repopath/url_maps/new'   ).to(repository_id: 'repopath',        action: :new     ) }
  it { expect(subject).to     route(:get,    'repositories/repopath/url_maps/2/edit').to(repository_id: 'repopath', id: 2, action: :edit    ) }
  it { expect(subject).to     route(:put,    'repositories/repopath/url_maps/2'     ).to(repository_id: 'repopath', id: 2, action: :update  ) }
  it { expect(subject).to     route(:delete, 'repositories/repopath/url_maps/2'     ).to(repository_id: 'repopath', id: 2, action: :destroy ) }
end
