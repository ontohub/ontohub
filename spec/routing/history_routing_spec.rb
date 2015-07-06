require 'spec_helper'

describe 'HistoryControllerRouting' do
  it { expect(subject).to route(:get, 'repositories/repopath/master/history').to(repository_id: 'repopath', controller: :history, action: :show, ref: 'master' ) }
end
