require 'spec_helper'

describe LanguageMappingsController do
  it do
    expect(subject).to route(:get, '/language_mappings').to(
      controller: :language_mappings, action: :index)
  end

  it do
    expect(subject).to route(:post, '/language_mappings').to(
      controller: :language_mappings, action: :create)
  end

  it do
    expect(subject).to route(:get, '/language_mappings/new').to(
      controller: :language_mappings, action: :new)
  end

  it do
    expect(subject).to route(:get, '/language_mappings/123/edit').to(
      controller: :language_mappings, action: :edit, id: 123)
  end

  it do
    expect(subject).to route(:get, '/language_mappings/123').to(
      controller: :language_mappings, action: :show, id: 123)
  end

  it do
    expect(subject).to route(:put, '/language_mappings/123').to(
      controller: :language_mappings, action: :update, id: 123)
  end

  it do
    expect(subject).to route(:delete, '/language_mappings/123').to(
      controller: :language_mappings, action: :destroy, id: 123)
  end
end
