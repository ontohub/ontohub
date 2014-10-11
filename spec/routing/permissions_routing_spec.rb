require 'spec_helper'

describe PermissionsController do
  it do
    should route(:get, '/repositories/my_repo/permissions').to(
      controller: :permissions, action: :index,
      repository_id: 'my_repo')
  end

  it do
    should route(:post, '/repositories/my_repo/permissions').to(
      controller: :permissions, action: :create,
      repository_id: 'my_repo')
  end

  it do
    should route(:put, '/repositories/my_repo/permissions/123').to(
      controller: :permissions, action: :update,
      repository_id: 'my_repo', id: 123)
  end

  it do
    should route(:delete, '/repositories/my_repo/permissions/123').to(
      controller: :permissions, action: :destroy,
      repository_id: 'my_repo', id: 123)
  end
end
