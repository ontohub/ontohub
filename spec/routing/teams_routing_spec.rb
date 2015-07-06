require 'spec_helper'

describe TeamsController do
  it do
    expect(subject).to route(:get, '/teams').to(
      controller: :teams, action: :index)
  end

  it do
    expect(subject).to route(:post, '/teams').to(
      controller: :teams, action: :create)
  end

  it do
    expect(subject).to route(:get, '/teams/new').to(
      controller: :teams, action: :new)
  end

  it do
    expect(subject).to route(:get, '/teams/123/edit').to(
      controller: :teams, action: :edit, id: 123)
  end

  it do
    expect(subject).to route(:get, '/teams/123').to(
      controller: :teams, action: :show, id: 123)
  end

  it do
    expect(subject).to route(:put, '/teams/123').to(
      controller: :teams, action: :update, id: 123)
  end

  it do
    expect(subject).to route(:delete, '/teams/123').to(
      controller: :teams, action: :destroy, id: 123)
  end
end
