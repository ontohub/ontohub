require 'spec_helper'

describe RepositoriesController do
  it do
    should route(:get, "/repositories").to(
      controller: :repositories, action: :index)
  end

  it do
    should route(:post, "/repositories").to(
      controller: :repositories, action: :create)
  end

  it do
    should route(:get, "/repositories/new").to(
      controller: :repositories, action: :new)
  end

  it do
    should route(:get, "/repositories/my_repo/edit").to(
      controller: :repositories, action: :edit, id: 'my_repo')
  end

  it do
    should route(:get, "/repositories/id").to(
      controller: :repositories, action: :show, id: 'id')
  end

  it do
    should route(:put, "/repositories/my_repo").to(
      controller: :repositories, action: :update, id: 'my_repo')
  end

  it do
    should route(:delete, "/repositories/my_repo").to(
      controller: :repositories, action: :destroy, id: 'my_repo')
  end
end
