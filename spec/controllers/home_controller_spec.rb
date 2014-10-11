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

  context 'on GET to index' do
    context 'not signed in' do
      before do
        get :index
      end
      it { should respond_with :success }
      it { should render_template :index }
      end

    context 'signed in' do
      before do
        sign_in FactoryGirl.create :user
        get :index
      end
      it { should respond_with :success }
      it { should render_template :index }
    end
  end
end
