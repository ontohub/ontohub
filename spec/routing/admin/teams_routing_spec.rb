require 'spec_helper'

describe Admin::TeamsController do
  it do
    should route(:get, '/admin/teams').to(
      controller: :'admin/teams', action: :index)
  end
end
