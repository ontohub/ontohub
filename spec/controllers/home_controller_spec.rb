require 'spec_helper'

describe HomeController do
  describe "show" do
    before { get :show }
    it { should respond_with :success }
    it { should render_template :show }
  end

  context 'on GET to index' do
    context 'not signed in' do
      before { get :index }
      it { should respond_with :success }
      it { should render_template :index }
      end

    context 'signed in' do
      before do
        sign_in create :user
        get :index
      end
      it { should respond_with :success }
      it { should render_template :index }
    end
  end
end
