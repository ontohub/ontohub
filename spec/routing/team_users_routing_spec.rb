require 'spec_helper'

describe TeamUsersController do
  it do
    expect(subject).to route(:get, '/teams/my_team/users').to(
      controller: :team_users, action: :index, team_id: 'my_team')
  end

  it do
    expect(subject).to route(:post, '/teams/my_team/users').to(
      controller: :team_users, action: :create, team_id: 'my_team')
  end

  it do
    expect(subject).to route(:put, '/teams/my_team/users/123').to(
      controller: :team_users, action: :update, team_id: 'my_team', id: 123)
  end

  it do
    expect(subject).to route(:delete, '/teams/my_team/users/123').to(
      controller: :team_users, action: :destroy, team_id: 'my_team', id: 123)
  end
end
