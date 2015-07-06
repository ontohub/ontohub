require 'spec_helper'

describe KeysController do
  it { expect(subject).to route(:get, "keys").to(:controller=> :keys, :action => :index) }
end
