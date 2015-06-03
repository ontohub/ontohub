require 'spec_helper'

describe Admin::UsersController do
  it do
    should route(:get, '/admin/users').to(
      controller: :'admin/users', action: :index)
  end

  it do
    should route(:post, '/admin/users').to(
      controller: :'admin/users', action: :create)
  end

  it do
    should route(:get, '/admin/users/new').to(
      controller: :'admin/users', action: :new)
  end

  it do
    should route(:get, '/admin/users/123/edit').to(
      controller: :'admin/users', action: :edit, id: 123)
  end

  it do
    should route(:get, '/admin/users/123').to(
      controller: :'admin/users', action: :show, id: 123)
  end

  it do
    should route(:put, '/admin/users/123').to(
      controller: :'admin/users', action: :update, id: 123)
  end

  it do
    should route(:delete, '/admin/users/123').to(
      controller: :'admin/users', action: :destroy, id: 123)
  end
end
