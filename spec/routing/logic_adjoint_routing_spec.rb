require 'spec_helper'

describe LogicAdjointsController do
  it do
    should route(:get, '/logic_adjoints').to(
      controller: :logic_adjoints, action: :index)
  end

  it do
    should route(:post, '/logic_adjoints').to(
      controller: :logic_adjoints, action: :create)
  end

  it do
    should route(:get, '/logic_adjoints/new').to(
      controller: :logic_adjoints, action: :new)
  end

  it do
    should route(:get, '/logic_adjoints/123/edit').to(
      controller: :logic_adjoints, action: :edit, id: 123)
  end

  it do
    should route(:get, '/logic_adjoints/123').to(
      controller: :logic_adjoints, action: :show, id: 123)
  end

  it do
    should route(:put, '/logic_adjoints/123').to(
      controller: :logic_adjoints, action: :update, id: 123)
  end

  it do
    should route(:delete, '/logic_adjoints/123').to(
      controller: :logic_adjoints, action: :destroy, id: 123)
  end
end
