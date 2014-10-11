require 'spec_helper'

describe LogicMappingsController do
  it do
    should route(:get, '/logic_mappings').to(
      controller: :logic_mappings, action: :index)
  end

  it do
    should route(:post, '/logic_mappings').to(
      controller: :logic_mappings, action: :create)
  end

  it do
    should route(:get, '/logic_mappings/new').to(
      controller: :logic_mappings, action: :new)
  end

  it do
    should route(:get, '/logic_mappings/123/edit').to(
      controller: :logic_mappings, action: :edit, id: 123)
  end

  it do
    should route(:get, '/logic_mappings/123').to(
      controller: :logic_mappings, action: :show, id: 123)
  end

  it do
    should route(:put, '/logic_mappings/123').to(
      controller: :logic_mappings, action: :update, id: 123)
  end

  it do
    should route(:delete, '/logic_mappings/123').to(
      controller: :logic_mappings, action: :destroy, id: 123)
  end
end
