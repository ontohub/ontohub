require 'spec_helper'

describe KeysController do
  it { should route(:get, "keys").to(:controller=> :keys, :action => :index) }
end
