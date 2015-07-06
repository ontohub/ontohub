require 'spec_helper'

describe GraphsController do
  it do
    expect(subject).to route(:get, "/logics/id/graphs").to(
      controller: :graphs, action: :index, logic_id: 'id')
  end
end
