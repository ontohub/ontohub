require 'spec_helper'

describe UsersController do
  it do
    should route(:get, '/users/id').to(
      controller: :users, action: :show, id: 'id')
  end
end
