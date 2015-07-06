require 'spec_helper'

describe HomeController do
  it { expect(subject).to route(:get, '/').to(controller: :home, action: :index) }
end
