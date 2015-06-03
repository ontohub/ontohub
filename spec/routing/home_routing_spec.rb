require 'spec_helper'

describe HomeController do
  it { should route(:get, '/').to(controller: :home, action: :index) }
end
