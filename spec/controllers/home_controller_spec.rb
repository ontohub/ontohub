require 'spec_helper'

describe HomeController do

  describe "show" do
    before { get :show }
    it { should respond_with :success }
    it { should render_template :show }

    describe 'csp headers' do
      subject{ response.headers["Content-Security-Policy-Report-Only"] }
      it{ should include "style-src 'self' 'unsafe-inline';" }
      it{ should include "script-src 'self';" }
    end
  end

end
