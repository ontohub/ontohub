require 'spec_helper'

describe 'DiffsControllerRouting' do
  it do
    should route(:get, 'repositories/repopath/master/diff').to(
      controller: :diffs, action: :show,
      repository_id: 'repopath', ref: 'master')
  end
end
