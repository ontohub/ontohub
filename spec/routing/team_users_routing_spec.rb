require 'spec_helper'

describe TeamUsersController do
  it do
    should route(:get, '/teams/my_team/users').to(
      controller: :team_users, action: :index, team_id: 'my_team')
  end

  it do
    should route(:post, '/teams/my_team/users').to(
      controller: :team_users, action: :create, team_id: 'my_team')
  end

  it do
    should route(:put, '/teams/my_team/users/123').to(
      controller: :team_users, action: :update, team_id: 'my_team', id: 123)
  end

  it do
    should route(:delete, '/teams/my_team/users/123').to(
      controller: :team_users, action: :destroy, team_id: 'my_team', id: 123)
  end
end
