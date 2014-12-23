require 'spec_helper'

describe AutocompleteController do
  it do
    should route(:get, "/autocomplete").
      to(controller: :autocomplete, action: :index)
  end
end
