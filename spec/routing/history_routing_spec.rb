require 'spec_helper'

describe 'HistoryControllerRouting' do
  it { should route(:get, 'repositories/repopath/master/history').to(repository_id: 'repopath', controller: :history, action: :show, ref: 'master' ) }
end
