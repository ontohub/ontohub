require 'spec_helper'

describe LogicMappingsController do
  it do
    should route(:get, '/serializations').to(
      controller: :serializations, action: :index)
  end

  it do
    should route(:post, '/serializations').to(
      controller: :serializations, action: :create)
  end

  it do
    should route(:get, '/serializations/new').to(
      controller: :serializations, action: :new)
  end

  it do
    should route(:get, '/serializations/123/edit').to(
      controller: :serializations, action: :edit, id: 123)
  end

  it do
    should route(:get, '/serializations/123').to(
      controller: :serializations, action: :show, id: 123)
  end

  it do
    should route(:put, '/serializations/123').to(
      controller: :serializations, action: :update, id: 123)
  end

  it do
    should route(:delete, '/serializations/123').to(
      controller: :serializations, action: :destroy, id: 123)
  end
end
