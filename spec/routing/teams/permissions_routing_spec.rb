require 'spec_helper'

describe PermissionsController do
  it do
    should route(:get, '/teams/my_team/permissions').to(
      controller: 'teams/permissions', action: :index,
      team_id: 'my_team')
  end
end
