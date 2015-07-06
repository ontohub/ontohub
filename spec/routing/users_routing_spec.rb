require 'spec_helper'

describe UsersController do
  it do
    expect(subject).to route(:get, '/users/id').to(
      controller: :users, action: :show, id: 'id')
  end
end
