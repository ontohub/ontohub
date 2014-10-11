require 'spec_helper'

describe LanguageAdjointsController do
  it do
    should route(:get, '/language_adjoints').to(
      controller: :language_adjoints, action: :index)
  end

  it do
    should route(:post, '/language_adjoints').to(
      controller: :language_adjoints, action: :create)
  end

  it do
    should route(:get, '/language_adjoints/new').to(
      controller: :language_adjoints, action: :new)
  end

  it do
    should route(:get, '/language_adjoints/123/edit').to(
      controller: :language_adjoints, action: :edit, id: 123)
  end

  it do
    should route(:get, '/language_adjoints/123').to(
      controller: :language_adjoints, action: :show, id: 123)
  end

  it do
    should route(:put, '/language_adjoints/123').to(
      controller: :language_adjoints, action: :update, id: 123)
  end

  it do
    should route(:delete, '/language_adjoints/123').to(
      controller: :language_adjoints, action: :destroy, id: 123)
  end
end
