require 'spec_helper'

describe TeamsController do
  it do
    should route(:get, '/teams').to(
      controller: :teams, action: :index)
  end

  it do
    should route(:post, '/teams').to(
      controller: :teams, action: :create)
  end

  it do
    should route(:get, '/teams/new').to(
      controller: :teams, action: :new)
  end

  it do
    should route(:get, '/teams/123/edit').to(
      controller: :teams, action: :edit, id: 123)
  end

  it do
    should route(:get, '/teams/123').to(
      controller: :teams, action: :show, id: 123)
  end

  it do
    should route(:put, '/teams/123').to(
      controller: :teams, action: :update, id: 123)
  end

  it do
    should route(:delete, '/teams/123').to(
      controller: :teams, action: :destroy, id: 123)
  end
end
