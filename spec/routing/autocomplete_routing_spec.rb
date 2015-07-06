require 'spec_helper'

describe AutocompleteController do
  it do
    expect(subject).to route(:get, "/autocomplete").
      to(controller: :autocomplete, action: :index)
  end
end
