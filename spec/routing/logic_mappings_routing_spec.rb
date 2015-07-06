require 'spec_helper'

describe LogicMappingsController do
  it do
    expect(subject).to route(:get, '/logic_mappings').to(
      controller: :logic_mappings, action: :index)
  end

  it do
    expect(subject).to route(:post, '/logic_mappings').to(
      controller: :logic_mappings, action: :create)
  end

  it do
    expect(subject).to route(:get, '/logic_mappings/new').to(
      controller: :logic_mappings, action: :new)
  end

  it do
    expect(subject).to route(:get, '/logic_mappings/my_logic_mapping/edit').to(
      controller: :logic_mappings, action: :edit, id: 'my_logic_mapping')
  end

  it do
    expect(subject).to route(:get, '/logic_mappings/my_logic_mapping').to(
      controller: :logic_mappings, action: :show, id: 'my_logic_mapping')
  end

  it do
    expect(subject).to route(:put, '/logic_mappings/my_logic_mapping').to(
      controller: :logic_mappings, action: :update, id: 'my_logic_mapping')
  end

  it do
    expect(subject).to route(:delete, '/logic_mappings/my_logic_mapping').to(
      controller: :logic_mappings, action: :destroy, id: 'my_logic_mapping')
  end
end
