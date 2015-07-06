require 'spec_helper'

describe HomeController do

  describe "show" do
    before { get :show }
    it { expect(subject).to respond_with :success }
    it { expect(subject).to render_template :show }

    describe 'csp headers' do
      subject{ response.headers["Content-Security-Policy-Report-Only"] }
      it{ expect(subject).to include "style-src 'self' 'unsafe-inline';" }
      it{ expect(subject).to include "script-src 'self';" }
    end
  end

  context 'on GET to index' do
    context 'not signed in' do
      before { get :index }
      it { expect(subject).to respond_with :success }
      it { expect(subject).to render_template :index }
      end

    context 'signed in' do
      before do
        sign_in create :user
        get :index
      end
      it { expect(subject).to respond_with :success }
      it { expect(subject).to render_template :index }
    end
  end
end
